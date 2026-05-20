--LL－バード・ストライク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「抒情歌鸲」怪兽存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
function c56619778.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「抒情歌鸲」怪兽存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56619778+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56619778.condition)
	e1:SetTarget(c56619778.target)
	e1:SetOperation(c56619778.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「抒情歌鸲」怪兽
function c56619778.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf7)
end
-- 发动条件：检查自己场上是否存在表侧表示的「抒情歌鸲」怪兽
function c56619778.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「抒情歌鸲」怪兽
	return Duel.IsExistingMatchingCard(c56619778.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果的发动准备：确认对方场上是否存在可无效的怪兽，并向系统宣告该效果
function c56619778.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只可以被无效效果的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被无效效果的表侧表示怪兽卡片组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，宣告将要无效对方场上这些怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理：使对方场上所有表侧表示怪兽的效果直到回合结束时无效
function c56619778.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有可以被无效效果的表侧表示怪兽卡片组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历获取到的怪兽卡片组，对每张卡进行效果无效处理
	for tc in aux.Next(g) do
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
