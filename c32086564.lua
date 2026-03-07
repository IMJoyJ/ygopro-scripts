--エクシーズ・トライバル
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，持有超量素材2个以上的超量怪兽不会被效果破坏。
-- ②：这张卡在魔法与陷阱区域存在，自己的超量怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽破坏。这个效果在那只自己怪兽持有超量素材2个以上的场合才能发动和处理。
function c32086564.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，持有超量素材2个以上的超量怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c32086564.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡在魔法与陷阱区域存在，自己的超量怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽破坏。这个效果在那只自己怪兽持有超量素材2个以上的场合才能发动和处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32086564,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c32086564.destg)
	e3:SetOperation(c32086564.desop)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否持有2个以上超量素材
function c32086564.target(e,c)
	return c:GetOverlayCount()>=2
end
-- 设置连锁处理时的破坏效果信息
function c32086564.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前正在战斗的怪兽（自己方和对方）
	local a,d=Duel.GetBattleMonster(tp)
	if chk==0 then return a and d and a:GetOverlayCount()>=2 end
	-- 设置连锁处理时的破坏效果目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 执行破坏对方怪兽的效果处理
function c32086564.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗的怪兽（自己方和对方）
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:GetOverlayCount()>=2 then
		-- 将对方怪兽因效果而破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
