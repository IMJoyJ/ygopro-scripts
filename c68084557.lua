--機械竜 パワー・ツール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己回合，这张卡有装备魔法卡被装备时才能发动。自己从卡组抽1张。
-- ②：1回合1次，以给其他怪兽装备的1张表侧表示的装备卡为对象才能发动。那张卡给这张卡装备。这个效果在对方回合也能发动。
function c68084557.initial_effect(c)
	-- 为这张卡添加同调召唤手续（调整＋调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己回合，这张卡有装备魔法卡被装备时才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(68084557,0))  --"抽卡"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_EQUIP)
	e1:SetCountLimit(1,68084557)
	e1:SetCondition(c68084557.drcon)
	e1:SetTarget(c68084557.drtg)
	e1:SetOperation(c68084557.drop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以给其他怪兽装备的1张表侧表示的装备卡为对象才能发动。那张卡给这张卡装备。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68084557,1))  --"装备转移"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c68084557.eqtg)
	e2:SetOperation(c68084557.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c68084557.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果①的发动准备与目标确认函数
function c68084557.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己是否能够从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为“玩家抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理函数
function c68084557.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤给其他怪兽装备的表侧表示装备卡的条件
function c68084557.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:GetEquipTarget() and c:GetEquipTarget()~=ec and c:CheckEquipTarget(ec)
end
-- 效果②的发动准备与目标选择函数
function c68084557.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c68084557.eqfilter(chkc,e:GetHandler()) end
	-- 在发动阶段检查场上是否存在可以作为对象的、给其他怪兽装备的表侧表示装备卡
	if chk==0 then return Duel.IsExistingTarget(c68084557.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1张给其他怪兽装备的表侧表示装备卡作为效果的对象
	Duel.SelectTarget(tp,c68084557.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
end
-- 效果②的效果处理函数
function c68084557.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的那张装备卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:CheckEquipTarget(c) then
		-- 将目标装备卡装备给这张卡
		Duel.Equip(tp,tc,c)
	end
end
