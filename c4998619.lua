--方界超獣バスター・ガンダイル
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升3000。
-- ②：这张卡在同1次的战斗阶段中可以作3次攻击。
-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
function c4998619.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。①：这个方法特殊召唤的这张卡的攻击力上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c4998619.spcon)
	e2:SetTarget(c4998619.sptg)
	e2:SetOperation(c4998619.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c4998619.spcon2)
	e4:SetTarget(c4998619.sptg2)
	e4:SetOperation(c4998619.spop2)
	c:RegisterEffect(e4)
end
-- 过滤出场上表侧表示、属于「方界」字段且可以作为特殊召唤代价送去墓地的怪兽。
function c4998619.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件判定：检查自己场上是否存在3只符合条件的「方界」怪兽，且将它们作为素材送去墓地后自己场上仍有可用的怪兽区域空位。
function c4998619.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可作为素材的「方界」怪兽（满足filter条件的怪兽组）。
	local mg=Duel.GetMatchingGroup(c4998619.filter,tp,LOCATION_MZONE,0,nil)
	-- 从上述怪兽组中检查是否存在3只怪兽，可以在作为素材送去墓地后让自己场上仍留有特殊召唤所需的空位。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤规则的目标选择处理：提示玩家从候选「方界」怪兽中选择3只作为送去墓地的素材，若选择成功则保存选择组并返回true。
function c4998619.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足条件的「方界」怪兽，作为可选的召唤素材候选。
	local mg=Duel.GetMatchingGroup(c4998619.filter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示选择提示“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选组中选择3只「方界」怪兽作为子组，并确认这些怪兽作为代价送去墓地后自己场上仍有可用怪兽区空位。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作处理：将之前选定的3只「方界」怪兽作为代价送去墓地，并为这张卡注册攻击力上升3000的效果。
function c4998619.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3只「方界」怪兽作为特殊召唤代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
	-- ①：这个方法特殊召唤的这张卡的攻击力上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(3000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- ③效果的发动条件判定：这张卡被对方送去墓地，且其被送去墓地前的控制者是发动方自己。
function c4998619.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤出自己墓地中属于「方界」字段且可以被当前效果特殊召唤的怪兽（同时满足召唤条件和苏生限制）。
function c4998619.spfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标选择处理：若为连锁对象合法性检查则确认该对象在自己墓地且可特殊召唤；若为发动时点检查则确认自己场上有空位且墓地存在至少1只符合条件的「方界」怪兽。
function c4998619.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4998619.spfilter(chkc,e,tp) end
	-- 效果发动时的合法性检查之一：自己场上存在可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时的合法性检查之二：自己墓地存在至少1只符合条件的「方界」怪兽可以作为对象。
		and Duel.IsExistingTarget(c4998619.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算本次可特殊召唤数量上限：取计划上限（青眼精灵龙存在时为1，否则为3）与当前可用怪兽区空位数量中的较小值。
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 弹出“请选择要特殊召唤的卡”的提示，供玩家选择特召对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1～上限只符合条件的「方界」怪兽作为特殊召唤对象，并将它们设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4998619.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 将本次效果处理信息标记为特殊召唤，记录对象为所选怪兽，数量为其张数，供后续发动相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤出卡组/墓地中属于「方界」字段且可以被加入手卡的卡。
function c4998619.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToHand()
end
-- ③效果处理：先检查可用怪兽区空位，若空位不足则结束；取回发动时选择且仍与效果相关的「方界」怪兽对象，若受青眼精灵龙效果影响且对象多于1只则效果不处理，若对象数多于空位则削减至空位数；将对象表侧表示特殊召唤，成功后从自己卡组·墓地选1张「方界」卡加入手卡，并展示给对手、洗切卡组。
function c4998619.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的主要怪兽区空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取回本次连锁的对象卡，并筛选出仍与该效果关联的「方界」怪兽（已离场或失去联系的对象除外）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 当对象数量超过可用空位需要削减时，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的「方界」怪兽以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回值不为0），则继续执行“那之后”的检索效果。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己卡组·墓地中所有「方界」且可以加入手卡、并且不受「王家长眠之谷」效果影响的卡，作为检索候选。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c4998619.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 存在可加入手卡的「方界」卡时，询问玩家是否将1张「方界」卡加入手卡。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(4998619,0)) then  --"是否把1张「方界」卡加入手卡？"
			-- 弹出“请选择要加入手牌的卡”的提示，供玩家选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			sg=sg:Select(tp,1,1,nil)
			-- 中断当前效果处理，使此后的检索加入手卡与之前的特殊召唤分为不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 将所选「方界」卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入手卡的「方界」卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
			-- 若加入手卡的卡来自卡组，则洗切自己的卡组。
			Duel.ShuffleDeck(tp)
		end
	end
end
