--綱引犬会
--not fully implemented
-- 效果：
-- ①：双方玩家在自身的抽卡阶段通常抽卡时，那是调整的场合，把那张卡给对方观看才能发动。把这个效果发动的玩家从卡组抽2张。
-- ②：这张卡的①的效果让对方抽卡的场合发动。自己失去2000基本分，这张卡送去墓地。
function c65938950.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在自身的抽卡阶段通常抽卡时，那是调整的场合，把那张卡给对方观看才能发动。把这个效果发动的玩家从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c65938950.drcon)
	e2:SetCost(c65938950.drcost)
	e2:SetTarget(c65938950.drtg)
	e2:SetOperation(c65938950.drop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果让对方抽卡的场合发动。自己失去2000基本分，这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EVENT_CUSTOM+65938950)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c65938950.lptg)
	e3:SetOperation(c65938950.lpop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c65938950.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定抽卡原因是否为规则抽卡，且抽卡玩家是否为当前回合玩家
	return r==REASON_RULE and tp==Duel.GetTurnPlayer()
end
-- 过滤出未公开且是调整怪兽的卡片
function c65938950.tdfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_TUNER)
end
-- 效果①的发动代价处理函数，用于展示抽到的调整怪兽
function c65938950.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:Filter(c65938950.tdfilter,1,nil)
	if chk==0 then return #tg>0 end
	-- 获取当前回合玩家
	local tunp=Duel.GetTurnPlayer()
	local tc=tg:GetFirst()
	if #tg>1 then
		-- 提示当前回合玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tunp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		tc=tg:Select(tunp,1,1,nil):GetFirst()
	end
	-- 给对方玩家确认选中的卡片
	Duel.ConfirmCards(1-tunp,tc)
	-- 洗切当前回合玩家的手卡
	Duel.ShuffleHand(tunp)
end
-- 效果①的靶向与操作信息设置函数
function c65938950.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前回合玩家
	local tunp=Duel.GetTurnPlayer()
	-- 在发动阶段，检查当前回合玩家是否可以效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tunp,2) end
	-- 设置效果处理信息为当前回合玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tunp,2)
end
-- 效果①的效果运行处理函数
function c65938950.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前回合玩家
	local tunp=Duel.GetTurnPlayer()
	local cp=e:GetHandlerPlayer()
	-- 让当前回合玩家效果抽2张卡，并判断是否为对方玩家抽卡
	if Duel.Draw(tunp,2,REASON_EFFECT)>0 and tunp~=cp then
		-- 触发自定义单体事件，以触发效果②
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+65938950,e,0,cp,0,0)
	end
end
-- 效果②的靶向与操作信息设置函数
function c65938950.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置效果处理信息为将这张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end
-- 效果②的效果运行处理函数
function c65938950.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己（此卡控制者）当前的生命值
	local lp=Duel.GetLP(tp)
	-- 将自己的生命值减少2000点
	Duel.SetLP(tp,lp-2000)
	-- 如果生命值成功减少且这张卡仍在场上
	if Duel.GetLP(tp)<lp and c:IsRelateToEffect(e) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
