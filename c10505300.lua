--スロワースワロー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有相同等级的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。下次的自己抽卡阶段的通常抽卡变成2张。
function c10505300.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有相同等级的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,10505300+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10505300.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。下次的自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10505300,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10505300.cost)
	e2:SetOperation(c10505300.operation)
	c:RegisterEffect(e2)
end
-- spfilter1用于判断“场上有相同等级的怪兽2只以上存在”：以一只表侧表示怪兽为基准，要求它等级大于0，且场上还存在另一只与此怪兽等级相同的表侧表示怪兽。
function c10505300.spfilter1(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
		-- 检查场上是否存在另一只与当前基准怪兽等级相同的表侧表示怪兽（排除当前基准怪兽自身），用于构成“相同等级怪兽2只以上”的条件。
		and Duel.IsExistingMatchingCard(c10505300.spfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
-- spfilter2用于筛选与指定等级lv相同的表侧表示怪兽，即寻找和基准怪兽等级相同的其他怪兽。
function c10505300.spfilter2(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
-- 特殊召唤规则效果的发动条件：这张卡若在手上（c非nil），需要己方主要怪兽区有空位，且双方场上存在至少一组同等级的表侧表示怪兽；c为nil时用于效果注册内部查询，返回true。
function c10505300.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己场上存在可以用于特殊召唤的空闲主要怪兽区格子。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认双方场上存在至少一只满足“有其他同等级表侧表示怪兽存在”的怪兽，即整体满足“场上存在相同等级的怪兽2只以上”。
		and Duel.IsExistingMatchingCard(c10505300.spfilter1,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ②效果的代价函数：发动前检查这张卡是否满足可被解放的条件；满足则实际将其解放作为代价。
function c10505300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡本身解放，作为②效果发动的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果处理：为当前玩家设置一个持续到下次己方抽卡阶段结束的效果，使其该次通常抽卡数量变为2张。
function c10505300.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己抽卡阶段的通常抽卡变成2张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	e1:SetValue(2)
	-- 将改变抽卡数量的永续效果注册给己方玩家，使其在下次抽卡阶段生效。
	Duel.RegisterEffect(e1,tp)
end
