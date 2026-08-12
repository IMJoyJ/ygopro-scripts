--ジャンク・ウォリアー／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：场上的这张卡不受对方发动的怪兽的效果影响。
-- ③：这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡号并创建多个效果
function s.initial_effect(c)
	-- 记录该卡与「爆裂体」和「爆裂模式」相关卡的关联
	aux.AddCodeList(c,60800381,80280737)
	-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过「爆裂模式」效果特殊召唤
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不受对方发动的怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(s.damcon)
	-- 设置战斗伤害变为2倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
s.assault_name=60800381
-- 计算攻击力提升值，等于场上「/爆裂体」怪兽数量乘以1000
function s.val(e,c)
	-- 获取场上自己方「/爆裂体」怪兽数量并乘以1000作为攻击力提升值
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*1000
end
-- 过滤场上自己方的「/爆裂体」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- 判断是否为对方发动的怪兽效果且未被王家长眠之谷影响
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤墓地中的「废品战士」同调怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(60800381) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra() and c:GetOwner()==tp
end
-- 设置效果目标为墓地中的「废品战士」同调怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，准备将目标卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 处理效果发动后的操作，将目标卡返回卡组并尝试特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 确认目标卡能被送入卡组且未受王家长眠之谷影响
		and aux.NecroValleyFilter()(tc) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 确认目标卡能被特殊召唤且场上存在召唤空间
		and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
		-- 询问玩家是否进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续效果错时处理
		Duel.BreakEffect()
		tc:SetMaterial(nil)
		-- 将目标卡以同调召唤方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断是否处于战斗阶段且有战斗对象
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
