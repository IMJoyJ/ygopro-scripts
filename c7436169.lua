--トリヴィカルマ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「维萨斯-斯塔弗罗斯特」和对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果无效，并让作为对象的自己怪兽的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
-- ②：把墓地的这张卡除外才能发动。把「三步业」以外的有「维萨斯-斯塔弗罗斯特」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①的效果（场上发动，无效对方怪兽并提升自己怪兽攻击力）和②的效果（墓地发动，除外自身检索记有「维萨斯-斯塔弗罗斯特」的魔陷）。
function s.initial_effect(c)
	-- 建立卡片关联，表明本卡的效果文本中记载了「维萨斯-斯塔弗罗斯特」的卡名。
	aux.AddCodeList(c,56099748)
	-- ①：以自己场上1只「维萨斯-斯塔弗罗斯特」和对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果无效，并让作为对象的自己怪兽的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把「三步业」以外的有「维萨斯-斯塔弗罗斯特」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「维萨斯-斯塔弗罗斯特」。
function s.filter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- 过滤条件：对方场上未被无效的效果怪兽，且其原本攻击力或原本守备力大于0。
function s.negfilter(c)
	-- 筛选未被无效的效果怪兽，且其原本攻击力或原本守备力至少有一项大于0（确保有可上升的数值）。
	return aux.NegateEffectMonsterFilter(c) and (c:GetBaseAttack()>0 or c:GetBaseDefense()>0)
end
-- ①的效果的发动准备：检查场上是否存在合法的对象，并进行取对象操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为对象的表侧表示「维萨斯-斯塔弗罗斯特」。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为对象的、未被无效且原本攻防不全为0的效果怪兽。
		and Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要作为效果对象的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只「维萨斯-斯塔弗罗斯特」作为对象。
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要无效的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只效果怪兽作为对象。
	local g2=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
	-- 设置操作信息：此效果包含“使怪兽效果无效”的操作，涉及卡片为选择的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- ①的效果的处理：使作为对象的对方怪兽效果无效，并使作为对象的自己怪兽攻击力上升该对方怪兽原本攻防中较高方数值的一半。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的卡片组（即自己和对方的各1只怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if #tg~=2 then return end
	if lc==tc then lc=tg:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		local upatk=tc:GetBaseAttack()
		if tc:GetBaseAttack()<tc:GetBaseDefense() then
			upatk=tc:GetBaseDefense()
		end
		-- 无效与该对方怪兽相关的已发动且正在处理的连锁。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if lc:IsRelateToEffect(e) and lc:IsControler(tp)
			and lc:IsFaceup() then
			-- 并让作为对象的自己怪兽的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(upatk/2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
		end
	end
end
-- 过滤条件：除「三步业」以外、记有「维萨斯-斯塔弗罗斯特」卡名的魔法·陷阱卡，且可以加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		-- 检查卡片效果文本中是否记载了「维萨斯-斯塔弗罗斯特」的卡名。
		and aux.IsCodeListed(c,56099748)
end
-- ②的效果的发动准备：检查卡组中是否存在可检索的卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：此效果包含“从卡组将1张卡加入手卡”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果的处理：从卡组选择1张满足条件的魔法·陷阱卡加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
