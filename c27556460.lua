--原石の反叫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽除外。
-- ②：自己准备阶段，自己场上有「原石」怪兽存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建并注册两个触发效果，分别对应召唤和特殊召唤时的无效与除外效果，以及一个准备阶段的盖放效果
function s.initial_effect(c)
	-- ①：除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段，自己场上有「原石」怪兽存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的「原石」怪兽（通常怪兽或5星以上原石怪兽且非衍生物）
function s.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsSetCard(0x1b9) and c:IsLevelAbove(5) or c:IsType(TYPE_NORMAL))
end
-- 判断条件：对方召唤或特殊召唤时，且当前无连锁处理，且自己场上存在满足条件的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方召唤或特殊召唤时，且当前无连锁处理
	return tp~=ep and Duel.GetCurrentChain()==0
		-- 判断自己场上存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置目标：确定将要无效召唤并除外的怪兽数量
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以除外目标怪兽
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置操作信息：将要无效召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将要除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- 效果发动：使召唤无效并除外目标怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 将目标怪兽除外
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- 过滤函数，用于判断场上是否存在满足条件的「原石」怪兽（正面表示且为原石）
function s.rccfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1b9)
end
-- 准备阶段盖放效果的发动条件：当前回合玩家为使用者，且自己场上存在满足条件的怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为使用者
	return Duel.GetTurnPlayer()==tp
		-- 判断自己场上存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置盖放效果的目标：将此卡盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：将此卡从墓地盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果的处理：将此卡盖放并设置其离场时的去向为除外
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以盖放，且未被王家长眠之谷影响，且盖放成功
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 设置效果：此卡离场时除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
