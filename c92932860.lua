--EMミス・ディレクター
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要自己场上有「异色眼」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：只要这张卡在怪兽区域守备表示存在，自己的「异色眼」怪兽不会被战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
-- ③：以自己墓地1只1星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材作同调召唤。
function c92932860.initial_effect(c)
	-- ①：只要自己场上有「异色眼」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c92932860.atcon)
	-- 设置不能成为攻击对象（对不受效果影响的怪兽无效）
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域守备表示存在，自己的「异色眼」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 作用目标：自己场上的「异色眼」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x99))
	e2:SetCondition(c92932860.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 作用目标：自己场上的「异色眼」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x99))
	e3:SetCondition(c92932860.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：以自己墓地1只1星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材作同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,92932860)
	e4:SetTarget(c92932860.sctg)
	e4:SetOperation(c92932860.scop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示的「异色眼」怪兽
function c92932860.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
-- 适用条件：自己场上有表侧表示的「异色眼」怪兽存在
function c92932860.atcon(e)
	-- 检查自己场上是否存在表侧表示的「异色眼」怪兽
	return Duel.IsExistingMatchingCard(c92932860.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 适用条件：自身在怪兽区域守备表示存在
function c92932860.indcon(e)
	return e:GetHandler():IsDefensePos()
end
-- 过滤条件：墓地可特殊召唤的1星怪兽，且能与自身同调召唤
function c92932860.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以以这两只怪兽为素材同调召唤的怪兽
		and Duel.IsExistingMatchingCard(c92932860.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件：可以以指定素材同调召唤的同调怪兽
function c92932860.scfilter2(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 发动效果处理：确认墓地1星怪兽目标合法性
function c92932860.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92932860.scfilter1(chkc,e,tp,c) end
	-- 检查玩家是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的1星怪兽
		and Duel.IsExistingTarget(c92932860.scfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的1星怪兽作为对象
	local g=Duel.SelectTarget(tp,c92932860.scfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	-- 设置操作信息：特殊召唤2只怪兽（包含额外卡组同调怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理：特殊召唤对象怪兽并将其效果无效，再以两只怪兽为素材进行同调召唤
function c92932860.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有可用空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 特殊召唤对象怪兽，若失败则结束处理
	if not tc:IsRelateToEffect(e) or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	-- 那只怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 刷新场上状态信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可同调召唤的怪兽
	local g=Duel.GetMatchingGroup(c92932860.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以两只怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
