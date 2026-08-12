--暗黒界の狩人 ブラウ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。自己从卡组抽1张。被对方的效果丢弃的场合，这个效果抽出的数量变成2张。
function c79126789.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。自己从卡组抽1张。被对方的效果丢弃的场合，这个效果抽出的数量变成2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79126789,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c79126789.drcon)
	e1:SetTarget(c79126789.drtg)
	e1:SetOperation(c79126789.drop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡之前的位置是手牌，且因效果被丢弃送去墓地，并记录其原本的控制者
function c79126789.drcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 设置效果发动的目标：确定抽卡玩家，并根据是否被对方效果丢弃来设置抽1张或2张的操作信息与目标参数
function c79126789.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	if rp==1-tp and tp==e:GetLabel() then
		-- 设置操作信息：由自己从卡组抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		-- 设置当前连锁的对象参数为2（抽2张卡）
		Duel.SetTargetParam(2)
	else
		-- 设置操作信息：由自己从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		-- 设置当前连锁的对象参数为1（抽1张卡）
		Duel.SetTargetParam(1)
	end
end
-- 执行效果处理：获取目标玩家和抽卡数量，执行抽卡
function c79126789.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
