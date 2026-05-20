--生存本能
-- 效果：
-- 把自己墓地存在的任意数量的恐龙族怪兽从游戏中除外。每除外1只恐龙族怪兽，自己回复400基本分。
function c58419204.initial_effect(c)
	-- 把自己墓地存在的任意数量的恐龙族怪兽从游戏中除外。每除外1只恐龙族怪兽，自己回复400基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c58419204.cost)
	e1:SetTarget(c58419204.target)
	e1:SetOperation(c58419204.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地可以作为代价除外的恐龙族怪兽
function c58419204.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：选择自己墓地任意数量的恐龙族怪兽除外，并记录对应的回复数值
function c58419204.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动检查时，确认自己墓地是否存在至少1只可以除外的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58419204.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地任意数量（1到63张）满足过滤条件的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c58419204.cfilter,tp,LOCATION_GRAVE,0,1,63,nil)
	e:SetLabel(g:GetCount()*400)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：设置回复的玩家、回复的数值以及操作信息
function c58419204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	-- 设置当前连锁的对象玩家为发动效果的玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为之前记录的回复数值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为：回复指定玩家指定数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
	e:SetLabel(0)
end
-- 效果处理：获取目标玩家和回复数值，执行回复生命值的操作
function c58419204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
