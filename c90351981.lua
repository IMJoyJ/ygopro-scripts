--オルフェゴール・バベル
-- 效果：
-- ①：只要这张卡在场地区域存在，原本卡名包含「自奏圣乐」的，自己场上的连接怪兽以及自己墓地的怪兽发动的效果变成对方回合也能发动的效果。
-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
function c90351981.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，原本卡名包含「自奏圣乐」的，自己场上的连接怪兽以及自己墓地的怪兽发动的效果变成对方回合也能发动的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(90351981)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90351981,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置发动条件：这张卡送去墓地的回合不能发动。
	e3:SetCondition(aux.exccon)
	e3:SetCost(c90351981.thcost)
	e3:SetTarget(c90351981.thtg)
	e3:SetOperation(c90351981.thop)
	c:RegisterEffect(e3)
end
-- 效果②的代价函数，用于检测和执行将手卡送去墓地的操作。
function c90351981.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检测手卡中是否存在可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡中选择1张可以作为代价送去墓地的卡送去墓地。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 效果②的目标过滤与操作信息设置函数，检测自身是否能加入手卡。
function c90351981.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将1张卡（即这张卡自身）加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数，将这张卡加入手卡。
function c90351981.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送回持有者的手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
