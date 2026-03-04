--エレキハダマグロ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果的函数入口
function s.initial_effect(c)
	-- ②：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果用于记录战斗伤害事件，以便后续效果①使用
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLE_DAMAGE)
		e3:SetCondition(s.regcon)
		e3:SetOperation(s.regop)
		-- 将效果e3注册为全局环境下的持续效果，监听战斗伤害事件
		Duel.RegisterEffect(e3,0)
	end
	-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.sscon)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
end
-- 判断效果①的发动条件：是否在己方怪兽造成战斗伤害后
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有标记表明刚刚造成了战斗伤害
	return Duel.GetFlagEffect(tp,id)>0
end
-- 设置效果①的目标处理逻辑
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认主怪兽区域有空位且此卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本次处理涉及特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果①的操作：特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若卡片仍有效果关联，则将其特殊召唤至场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 判断效果e3的触发条件：是否是对方受到战斗伤害
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=rp
end
-- 执行效果e3的操作：注册一个标记供后续效果①使用
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 在玩家受到战斗伤害的阶段结束时注册一次性的标记
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 判断效果③的发动条件：是否由自己直接攻击造成战斗伤害
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保是由对方玩家受到伤害且没有攻击对象（即直接攻击）
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
-- 定义筛选条件：非调整、正面表示且等级大于0的怪兽
function s.mfilter(c)
	return not c:IsType(TYPE_TUNER) and c:IsFaceupEx() and c:GetLevel()>0
end
-- 定义可特殊召唤的「电气」同调怪兽的筛选条件
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(0xe) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,1,#g,tp,e:GetHandler(),c)
end
-- 定义用于检查解放组合是否满足同调召唤等级要求的函数
function s.gcheck(g,tp,ec,sc)
	-- 验证额外怪兽区是否有空间，并计算解放怪兽总等级是否匹配目标同调怪兽
	return Duel.GetLocationCountFromEx(tp,tp,g+ec,sc)>0 and g:GetSum(Card.GetLevel)+ec:GetLevel()==sc:GetLevel()
end
-- 设置效果③的目标处理逻辑
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取可用于解放的怪兽组并排除当前卡
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if chk==0 then return c:IsReleasableByEffect() and c:GetLevel()>0
		-- 确认存在符合条件的「电气」同调怪兽可供特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息，标明本次处理涉及至少两次解放操作
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,0,0)
end
-- 执行效果③的操作：选择并特殊召唤合适的同调怪兽
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次获取可用于解放的怪兽组并排除当前卡
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if not (c:IsRelateToEffect(e) and c:IsReleasableByEffect()) or #g==0 then return end
	-- 提示玩家选择要特殊召唤的「电气」同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家选择一只符合条件的「电气」同调怪兽进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
	if tc then
		-- 提示玩家选择需要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,#g,tp,c,tc)+c
		-- 若成功解放所选怪兽，则特殊召唤之前选定的同调怪兽
		if Duel.Release(sg,REASON_EFFECT)>0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	end
end
