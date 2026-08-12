--スワローズ・カウリー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己的手卡·场上（表侧表示）1只鸟兽族怪兽解放才能发动。等级和解放的怪兽相同的1只鸟兽族怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 定义卡片初始化效果，注册魔法卡发动效果，设置同名卡一回合只能发动一次的限制
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己的手卡·场上（表侧表示）1只鸟兽族怪兽解放才能发动。等级和解放的怪兽相同的1只鸟兽族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 代价检测与处理函数，用于在发动时标记代价检测状态
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤可解放怪兽的条件：手卡或场上表侧表示的鸟兽族怪兽，且卡组中存在与其等级相同的可检索鸟兽族怪兽
function s.cfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsReleasable() and c:IsFaceupEx()
		-- 检查卡组中是否存在与该怪兽等级相同的、可加入手牌的鸟兽族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 过滤要检索的怪兽的条件：卡组中与解放怪兽等级相同的、可加入手牌的鸟兽族怪兽
function s.thfilter(c,lv)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(lv) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与代价支付处理：验证并解放1只鸟兽族怪兽，记录其等级，并设置检索的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手卡和场上所有满足解放条件且能配合卡组检索的鸟兽族怪兽组
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.cfilter,nil,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return g:GetCount()>=1
	end
	local rg=g:FilterSelect(tp,s.cfilter,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(rg,REASON_COST)
	-- 设置连锁处理的操作信息，表示此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组中选择1只与解放怪兽等级相同的鸟兽族怪兽加入手卡并展示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只等级与解放怪兽相同的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
