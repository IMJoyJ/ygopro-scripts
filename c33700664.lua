--異解△領域－ヴァルヴォルス
-- 效果：
-- 从自己的卡组上面·墓地把合计5张卡里侧除外才能把这张卡发动。这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。「异解△领域-瓦尔涡罗斯」以外的自己的除外状态（里侧）的1张「异解△」卡加入手卡。
-- ②：只要自己场上有5星以上的「异解△」怪兽存在并是自己卡组数量是0张，自己回合内，对方不能把卡的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动（e1）、效果①（起动效果加入手卡）与效果②（永续效果封锁对方效果发动）
function s.initial_effect(c)
	-- 从自己的卡组上面·墓地把合计5张卡里侧除外才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。「异解△领域-瓦尔涡罗斯」以外的自己的除外状态（里侧）的1张「异解△」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有5星以上的「异解△」怪兽存在并是自己卡组数量是0张，自己回合内，对方不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.limcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 卡片发动Cost：从自己的卡组顶端·墓地把合计5张卡里侧除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方卡组中能够以里侧表示除外的卡片数量
	local dct=Duel.GetMatchingGroupCount(Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK,0,nil,POS_FACEDOWN)
	-- 检查卡组与墓地能够以里侧表示除外的卡片合计是否至少有5张
	if chk==0 then return dct>=5 or dct<5 and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,5-dct,nil,POS_FACEDOWN) end
	if dct>5 then dct=5 end
	local gg=Group.CreateGroup()
	-- 若卡组卡片足够且墓地存在可里侧除外的卡
	if dct>=5 and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil,POS_FACEDOWN)
		-- 询问玩家是否选择除外墓地的卡来发动
		and Duel.SelectYesNo(tp,aux.Stringid(id,0))  --"是否除外墓地的卡来发动？"
		or dct<5 then
		local st=dct
		if st==5 then st=4 end
		-- 提示玩家选择要里侧除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从墓地选择对应数量的卡片
		gg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,5-st,5,nil,POS_FACEDOWN)
		-- 显示墓地选中的卡片被选为对象的提示
		Duel.HintSelection(gg)
	end
	if gg:GetCount()>0 then
		dct=5-gg:GetCount()
	end
	-- 获取卡组顶端需要除外的卡片组
	local dg=Duel.GetDecktopGroup(tp,dct)
	if dct<5 then
		dg:Merge(gg)
	end
	-- 关闭除外卡片时的自动洗卡检测
	Duel.DisableShuffleCheck()
	-- 将卡组顶端与墓地选中的卡片以里侧表示除外作为Cost
	if Duel.Remove(dg,POS_FACEDOWN,REASON_COST)~=0 then
		-- 遍历所有被里侧除外的卡片并为其实测注册本卡标记
		for tc in aux.Next(dg) do
			if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"因「异解△领域-瓦尔涡罗斯」被里侧除外"
			end
		end
	end
end
-- 过滤条件：同名卡以外的自己的里侧除外状态的「异解△」卡
function s.thfilter(c)
	return c:IsFacedown() and not c:IsCode(id) and c:IsSetCard(0x1ed) and c:IsAbleToHand()
end
-- 效果①发动条件判断及操作信息设置：将里侧除外状态的卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的里侧除外状态的「异解△」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从除外区将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果①处理：将选中的1张里侧除外的「异解△」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张里侧除外状态的「异解△」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：场上表侧表示的5星以上「异解△」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ed) and c:IsLevelAbove(5)
end
-- 效果②生效条件：场上有5星以上「异解△」怪兽、自己卡组为0张且在自己回合
function s.limcon(e)
	-- 检查自己场上是否存在5星以上的「异解△」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组剩余卡片数量是否为0
		and Duel.GetMatchingGroupCount(aux.TRUE,e:GetHandlerPlayer(),LOCATION_DECK,0,nil)==0
		-- 检查当前回合是否为自己的回合
		and Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
