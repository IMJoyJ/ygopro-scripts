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
-- 检查是否满足效果发动条件：攻击怪兽是此卡，攻击目标存在且为表侧守备表示且与战斗相关
function c4041838.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击战斗中的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 判断攻击怪兽是否为此卡
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsFaceup() and d:IsDefensePos() and d:IsRelateToBattle() end
	-- 设置连锁操作信息为破坏效果，目标为攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理函数，判断攻击目标是否满足破坏条件并执行破坏
function c4041838.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
