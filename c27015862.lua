--ヴェーダ＝カーランタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的卡被效果破坏的场合，若场上有「维萨斯-斯塔弗罗斯特」存在则能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「新世坏」加入手卡。
-- ②：这张卡以外的自己怪兽被效果破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
local s,id,o=GetID()
-- 创建卡片效果，注册两个诱发效果，分别对应①②效果
function s.initial_effect(c)
	-- 记录该卡具有「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- 效果①：场上的卡被效果破坏的场合，若场上有「维萨斯-斯塔弗罗斯特」存在则能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「新世坏」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡以外的自己怪兽被效果破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"对方怪兽破坏"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断被破坏的卡是否为效果破坏且在场上
function s.desfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：判断场上的卡是否为「维萨斯-斯塔弗罗斯特」且表侧表示
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- 效果①的发动条件：场上被效果破坏的卡中存在满足desfilter条件的卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil)
end
-- 效果①的发动时点处理：判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上有无「维萨斯-斯塔弗罗斯特」
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：判断是否为「新世坏」且能加入手牌
function s.thfilter(c)
	return c:IsCode(21570001) and c:IsAbleToHand()
end
-- 效果①的处理：特殊召唤该卡，并可选择将「新世坏」加入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若失败则返回
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取满足条件的「新世坏」卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 判断是否有满足条件的「新世坏」且玩家选择加入手牌
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「新世坏」加入手卡？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tag=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(tag,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,tag)
	end
end
-- 过滤函数：判断被破坏的卡是否为己方怪兽且为效果破坏
function s.desfilter2(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：场上被效果破坏的卡中存在满足desfilter2条件的卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter2,1,nil,tp)
end
-- 效果②的发动时点处理：选择对方场上一只怪兽作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在可破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将该卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理：破坏对象怪兽，并使自身攻击力上升该怪兽原本攻击力数值
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 设置自身攻击力提升效果，提升数值为被破坏怪兽的原本攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
