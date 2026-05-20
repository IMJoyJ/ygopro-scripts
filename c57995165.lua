--おろかな重葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把魔法·陷阱卡盖放。
-- ①：把基本分支付一半才能发动。从额外卡组把1只怪兽送去墓地。
function c57995165.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把魔法·陷阱卡盖放。①：把基本分支付一半才能发动。从额外卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57995165+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c57995165.cost)
	e1:SetTarget(c57995165.target)
	e1:SetOperation(c57995165.activate)
	c:RegisterEffect(e1)
	if not c57995165.global_check then
		c57995165.global_check=true
		-- 这张卡发动的回合，自己不能把魔法·陷阱卡盖放。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c57995165.checkop)
		-- 注册全局环境效果，用于监控玩家盖放魔法·陷阱卡的操作
		Duel.RegisterEffect(ge1,0)
	end
end
-- 盖放魔法·陷阱卡时的操作函数，为盖放魔陷的玩家注册一个回合内有效的标识效果
function c57995165.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为盖放魔法·陷阱卡的玩家注册一个持续到回合结束的标识效果，用于记录该玩家在本回合已经盖放过魔陷
	Duel.RegisterFlagEffect(rp,57995165,RESET_PHASE+PHASE_END,0,1)
end
-- 发动代价与限制检查函数，检查本回合是否盖放过魔陷，并支付一半生命值，同时适用本回合不能盖放魔陷的限制
function c57995165.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段，确保玩家在本回合没有盖放过魔法·陷阱卡
	if chk==0 then return Duel.GetFlagEffect(tp,57995165)==0 end
	-- 支付一半的当前生命值作为发动的代价
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 这张卡发动的回合，自己不能把魔法·陷阱卡盖放。①：把基本分支付一半才能发动。从额外卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给发动玩家注册“不能盖放魔法·陷阱卡”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于筛选可以送去墓地的卡片
function c57995165.tgfilter(c)
	return c:IsAbleToGrave()
end
-- 效果发动目标函数，检查额外卡组是否存在可送去墓地的怪兽，并设置送去墓地的操作信息
function c57995165.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段，确认自己额外卡组是否存在至少1张可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57995165.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将自己额外卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，让玩家从额外卡组选择1只怪兽送去墓地
function c57995165.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的额外卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c57995165.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
