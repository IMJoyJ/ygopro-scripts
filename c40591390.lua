--D-HERO ドレッドガイ
-- 效果：
-- 「幽狱之时计塔」的效果特殊召唤的场合，自己场上名字带有「命运英雄」的怪兽以外的自己怪兽全部破坏。那之后，可以从自己墓地把最多2只名字带有「命运英雄」的怪兽特殊召唤。这张卡特殊召唤的回合，自己场上的名字带有「命运英雄」的怪兽不会被破坏，对控制者的战斗伤害变成0。这张卡的攻击力·守备力变成自己场上除这张卡外的名字带有「命运英雄」的怪兽的原本攻击力合计数值。
function c40591390.initial_effect(c)
	-- 记录该卡与「幽狱之时计塔」（75041269）的关联
	aux.AddCodeList(c,75041269)
	-- 「幽狱之时计塔」的效果特殊召唤的场合，自己场上名字带有「命运英雄」的怪兽以外的自己怪兽全部破坏。那之后，可以从自己墓地把最多2只名字带有「命运英雄」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40591390,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c40591390.spcon)
	e1:SetTarget(c40591390.sptg)
	e1:SetOperation(c40591390.spop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的回合，自己场上的名字带有「命运英雄」的怪兽不会被破坏，对控制者的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c40591390.indop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力变成自己场上除这张卡外的名字带有「命运英雄」的怪兽的原本攻击力合计数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetValue(c40591390.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
end
-- 判断是否由「幽狱之时计塔」的效果特殊召唤
function c40591390.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(75041269)
end
-- 过滤场上非「命运英雄」怪兽或里侧表示怪兽
function c40591390.desfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xc008)
end
-- 设置破坏效果的操作信息
function c40591390.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取需要被破坏的怪兽组
	local g=Duel.GetMatchingGroup(c40591390.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤墓地符合条件的「命运英雄」怪兽
function c40591390.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤相关逻辑
function c40591390.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取需要被破坏的怪兽组
	local g=Duel.GetMatchingGroup(c40591390.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 将目标怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取玩家场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取可特殊召唤的「命运英雄」怪兽组
	g=Duel.GetMatchingGroup(c40591390.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 判断是否有符合条件的怪兽且玩家选择特殊召唤
	if g:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(40591390,1)) then  --"是否要特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上「命运英雄」怪兽
function c40591390.filter(e,c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 注册战斗破坏、效果破坏免疫及战斗伤害为0效果
function c40591390.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 注册战斗破坏、效果破坏免疫及战斗伤害为0效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c40591390.filter)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗破坏免疫效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 注册效果破坏免疫效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	-- 注册战斗伤害为0效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤场上「命运英雄」怪兽
function c40591390.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 计算「命运英雄」怪兽攻击力总和
function c40591390.val(e,c)
	-- 获取场上「命运英雄」怪兽组
	local g=Duel.GetMatchingGroup(c40591390.vfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetBaseAttack)
end
