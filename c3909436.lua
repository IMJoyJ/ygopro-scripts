--ヴェンデット・バスタード
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1张「复仇死者」卡除外，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，对方不能把宣言的种类的卡的效果发动。
-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
function c3909436.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：从自己墓地把1张「复仇死者」卡除外，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，对方不能把宣言的种类的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3909436,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,3909436)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c3909436.cost)
	e1:SetTarget(c3909436.target)
	e1:SetOperation(c3909436.operation)
	c:RegisterEffect(e1)
	-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3909436,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3909437)
	e2:SetCondition(c3909436.thcon)
	e2:SetTarget(c3909436.thtg)
	e2:SetOperation(c3909436.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c3909436.cfilter(c)
	return c:IsSetCard(0x106) and c:IsAbleToRemoveAsCost()
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c3909436.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3909436.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 过滤函数，让玩家sel_player选择以player来看的指定位置满足过滤条件f并且不等于ex的min-max张卡
	local g=Duel.SelectMatchingCard(tp,c3909436.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 以reason原因，pos表示形式除外targets，返回值是实际被操作的数量
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c3909436.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片类型（怪兽·魔法·陷阱）
	e:SetLabel(Duel.AnnounceType(tp))
end
-- 创建一个效果并注册给全局环境
function c3909436.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：从自己墓地把1张「复仇死者」卡除外，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，对方不能把宣言的种类的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	if e:GetLabel()==0 then
		e1:SetDescription(aux.Stringid(3909436,2))
		e1:SetValue(c3909436.aclimit1)
	elseif e:GetLabel()==1 then
		e1:SetDescription(aux.Stringid(3909436,3))
		e1:SetValue(c3909436.aclimit2)
	else
		e1:SetDescription(aux.Stringid(3909436,4))
		e1:SetValue(c3909436.aclimit3)
	end
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把效果e作为玩家player的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：限制对方发动怪兽类型的效果
function c3909436.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 效果作用：限制对方发动魔法类型的效果
function c3909436.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL)
end
-- 效果作用：限制对方发动陷阱类型的效果
function c3909436.aclimit3(e,re,tp)
	return re:IsActiveType(TYPE_TRAP)
end
-- 效果作用：仪式召唤的这张卡被送去墓地的场合才能发动
function c3909436.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c3909436.thfilter(c,tp)
	return bit.band(c:GetType(),TYPE_RITUAL+TYPE_MONSTER)==TYPE_RITUAL+TYPE_MONSTER and c:IsAbleToHand()
		-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
		and Duel.IsExistingMatchingCard(c3909436.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c3909436.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106) and c:IsAbleToGrave()
end
-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
function c3909436.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 过滤函数，检查以玩家来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3909436.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从卡组把1只仪式怪兽加入手卡，从卡组把1只「复仇死者」怪兽送去墓地
function c3909436.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 过滤函数，让玩家sel_player选择以player来看的指定位置满足过滤条件f并且不等于ex的min-max张卡
	local hg=Duel.SelectMatchingCard(tp,c3909436.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 以reason原因把targets送去玩家player的手卡，返回值是实际被操作的数量
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给玩家player确认targets
		Duel.ConfirmCards(1-tp,hg)
		-- 给玩家发送提示信息，提示内容为desc
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 过滤函数，让玩家sel_player选择以player来看的指定位置满足过滤条件f并且不等于ex的min-max张卡
		local g=Duel.SelectMatchingCard(tp,c3909436.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 以reason原因把targets送去墓地，返回值是实际被操作的数量
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
