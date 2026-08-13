--D・スコープン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：1回合1次，可以从手卡把1只4星的名字带有「变形斗士」的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
-- ●守备表示：只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
function c10591919.initial_effect(c)
	-- ●攻击表示：1回合1次，可以从手卡把1只4星的名字带有「变形斗士」的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10591919,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c10591919.cona)
	e1:SetTarget(c10591919.tga)
	e1:SetOperation(c10591919.opa)
	c:RegisterEffect(e1)
	-- ●守备表示：只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetCondition(c10591919.cond)
	e2:SetValue(4)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一张卡是否为手牌中4星且名字带有「变形斗士」、并能被该效果特殊召唤的怪兽，作为选择特殊召唤对象的筛选条件。
function c10591919.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 攻击表示效果的发动条件：自身没有被无效化，且当前处于攻击表示。
function c10591919.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 目标检测：确认发动时自己主要怪兽区有空位，且手牌中存在符合条件的「变形斗士」怪兽可被特殊召唤。
function c10591919.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时先检查自己主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查手牌中是否存在至少1张满足c10591919.filter条件的怪兽。
		and Duel.IsExistingMatchingCard(c10591919.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：宣告本效果将从手卡特殊召唤1只怪兽，供系统进行相关效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行攻击表示效果：选择手牌中符合条件的「变形斗士」怪兽特殊召唤，并为该怪兽注册结束阶段破坏的持续效果，确保其在结束阶段被破坏。
function c10591919.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足c10591919.filter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c10591919.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(10591919,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 这个效果特殊召唤的怪兽在结束阶段时破坏。●守备表示：只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c10591919.descon)
	e1:SetOperation(c10591919.desop)
	-- 将结束阶段破坏效果的诱发效果注册到决斗中，使其在结束阶段时触发。
	Duel.RegisterEffect(e1,tp)
end
-- 破坏效果的触发条件：通过标记确认要破坏的怪兽仍然是本次特殊召唤的那只怪兽；如果标记不一致则重置该效果并不再处理。
function c10591919.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(10591919)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏效果的处理：在结束阶段时对标记怪兽执行破坏动作。
function c10591919.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将被特殊召唤的怪兽破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 守备表示等级变化效果的条件：该卡处于守备表示。
function c10591919.cond(e)
	return e:GetHandler():IsDefensePos()
end
