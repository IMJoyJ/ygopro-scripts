--罰則金
-- 效果：
-- 自己把手卡2张丢弃。
function c92595643.initial_effect(c)
	-- 自己把手卡2张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c92595643.target)
	e1:SetOperation(c92595643.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与检测函数
function c92595643.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少2张卡（不包括此卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,2)
end
-- 效果处理（发动）函数
function c92595643.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让该玩家选择并以效果和丢弃的原因将2张手卡送去墓地
	Duel.DiscardHand(p,nil,2,2,REASON_EFFECT+REASON_DISCARD)
end
