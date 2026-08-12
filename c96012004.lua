--ラッキー・チャンス！
-- 效果：
-- 进行1次投掷硬币的效果怪兽的效果发动时对硬币的里表作猜测。猜中的场合，从自己卡组抽1张卡。
function c96012004.initial_effect(c)
	-- 进行1次投掷硬币的效果怪兽的效果发动时对硬币的里表作猜测。猜中的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96012004.cointg)
	e1:SetOperation(c96012004.coinop)
	c:RegisterEffect(e1)
	-- 进行1次投掷硬币的效果怪兽的效果发动时对硬币的里表作猜测。猜中的场合，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96012004,0))  --"猜硬币"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c96012004.coincon)
	e2:SetOperation(c96012004.coinop)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
end
-- 判断发动效果的卡是否为进行1次投掷硬币的效果怪兽，并保存该效果
function c96012004.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果中关于投掷硬币的操作信息
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct==1 and re:IsActiveType(TYPE_MONSTER) then
		e:SetLabelObject(re)
		return true
	else return false end
end
-- 卡片发动时的效果处理，若连锁1是满足条件的怪兽效果，则允许玩家选择是否进行猜测
function c96012004.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 获取当前的连锁数
	local cc=Duel.GetCurrentChain()
	if cc==1 then return end
	-- 获取前一个连锁的效果
	local te=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_EFFECT)
	-- 获取前一个连锁效果中关于投掷硬币的操作信息
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(cc-1,CATEGORY_COIN)
	-- 如果前一个连锁是进行1次投掷硬币的效果怪兽的效果，则询问玩家是否进行猜测
	if ex and ct==1 and te:IsActiveType(TYPE_MONSTER) and Duel.SelectYesNo(tp,94) then
		e:SetLabel(1)
		e:SetLabelObject(te)
	end
end
-- 猜测硬币正反面的效果处理，并注册一个用于在投掷硬币结果确定时进行判断的临时效果
function c96012004.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then return end
	-- 如果是已在场上发动的效果，且当前连锁不是紧跟在目标怪兽效果之后，则不处理
	if e:GetLabel()==2 and Duel.GetCurrentChain()~=ev+1 then return end
	-- 提示玩家选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面
	local res=1-Duel.AnnounceCoin(tp)
	-- 猜中的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TOSS_COIN)
	e1:SetCondition(c96012004.drcon)
	e1:SetOperation(c96012004.drop)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetLabel(res)
	-- 注册用于在硬币投掷结果产生后进行判定的临时效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查投掷硬币的效果是否为目标怪兽的效果，且投掷结果是否与玩家猜测的一致
function c96012004.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前投掷硬币的结果
	local res=Duel.GetCoinResult()
	return re==e:GetLabelObject() and res==e:GetLabel()
end
-- 猜中硬币正反面时的抽卡效果处理
function c96012004.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显式展示本卡的效果发动提示
	Duel.Hint(HINT_CARD,0,96012004)
	-- 从自己卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
