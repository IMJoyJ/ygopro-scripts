--フレッシュマドルチェ・シスタルト
-- 效果：
-- 「魔偶甜点」怪兽2只
-- ①：只要这张卡所连接区有「魔偶甜点」怪兽存在，自己场上的「魔偶甜点」魔法·陷阱卡不会被效果破坏，双方不能把那些卡作为效果的对象。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替让自己墓地1只「魔偶甜点」怪兽回到卡组。
function c96150936.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只「魔偶甜点」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x71),2,2)
	-- ①：只要这张卡所连接区有「魔偶甜点」怪兽存在，自己场上的「魔偶甜点」魔法·陷阱卡不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(c96150936.indescon)
	e1:SetTarget(c96150936.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替让自己墓地1只「魔偶甜点」怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c96150936.desreptg)
	e3:SetOperation(c96150936.desrepop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的「魔偶甜点」卡
function c96150936.indesfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 效果1的启用条件：这张卡的所连接区存在「魔偶甜点」怪兽
function c96150936.indescon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c96150936.indesfilter,1,nil)
end
-- 效果1的适用对象：自己场上的「魔偶甜点」魔法·陷阱卡
function c96150936.indestg(e,c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：自己墓地中可以回到卡组的「魔偶甜点」怪兽（且不受「王家长眠之谷」影响）
function c96150936.desrepfilter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
-- 代替破坏效果的条件检查：这张卡因战斗或效果将被破坏，且不是因为其他代替效果而破坏
function c96150936.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己墓地是否存在至少1只满足代替条件的「魔偶甜点」怪兽
		and Duel.IsExistingMatchingCard(c96150936.desrepfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否选择发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的具体处理：选择自己墓地1只「魔偶甜点」怪兽回到卡组
function c96150936.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的「魔偶甜点」怪兽
	local g=Duel.SelectMatchingCard(tp,c96150936.desrepfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 为选中的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的怪兽送回卡组并洗牌，作为代替破坏的处理
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_REPLACE)
end
