--忍者マスター SASUKE
-- 效果：
-- 这张卡攻击表侧守备表示的怪兽的场合，不进入伤害计算，那只怪兽直接破坏。
function c4041838.initial_effect(c)
	-- 这张卡攻击表侧守备表示的怪兽的场合，不进入伤害计算，那只怪兽直接破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4041838,0))  --"破坏表侧守备怪物"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c4041838.targ)
	e1:SetOperation(c4041838.op)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定：确认攻击者为此卡，且攻击目标存在、为表侧表示、为守备表示并与此战斗相关联。
function c4041838.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗中被这张卡攻击的怪兽。
	local d=Duel.GetAttackTarget()
	-- 判定发起攻击的怪兽是否为效果持有者（这张卡）。
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsFaceup() and d:IsDefensePos() and d:IsRelateToBattle() end
	-- 设置操作信息：将攻击目标登记为将被效果破坏的1张卡，供连锁与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理阶段：若攻击目标仍与本次战斗关联且为守备表示，则将其破坏。
function c4041838.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前战斗的攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 以效果原因将攻击目标怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
