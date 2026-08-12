--ライトロード・プリースト ジェニス
-- 效果：
-- 名字带有「光道」的卡的效果从自己卡组把卡送去墓地的回合的结束阶段时，给与对方基本分500分伤害，自己回复500基本分。
function c83725008.initial_effect(c)
	-- 名字带有「光道」的卡的效果从自己卡组把卡送去墓地的回合的结束阶段时，给与对方基本分500分伤害，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83725008,0))  --"伤害，回复"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c83725008.lpcon)
	e1:SetTarget(c83725008.lptg)
	e1:SetOperation(c83725008.lpop)
	c:RegisterEffect(e1)
	if c83725008.discard==nil then
		c83725008.discard=true
		c83725008[0]=false
		c83725008[1]=false
		-- 名字带有「光道」的卡的效果从自己卡组把卡送去墓地的回合
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(c83725008.reset)
		-- 注册全局效果，用于在每个回合开始时重置送墓标记
		Duel.RegisterEffect(e2,0)
		-- 名字带有「光道」的卡的效果从自己卡组把卡送去墓地
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_TO_GRAVE)
		e3:SetOperation(c83725008.set)
		-- 注册全局效果，用于监听并记录「光道」卡片效果从卡组送墓的事件
		Duel.RegisterEffect(e3,0)
	end
end
-- 重置双方玩家在当前回合是否有「光道」卡片效果从卡组送墓的标记
function c83725008.reset(e,tp,eg,ep,ev,re,r,rp)
	c83725008[0]=false
	c83725008[1]=false
end
-- 过滤条件：检查卡片原本的位置是否是卡组
function c83725008.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 监听送墓事件，若因「光道」卡片的效果将卡从卡组送去墓地，则标记该玩家
function c83725008.set(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if bit.band(r,REASON_EFFECT)>0 and rc:IsSetCard(0x38) and eg:IsExists(c83725008.cfilter,1,nil) then
		c83725008[rp]=true
	end
end
-- 效果发动条件：当前回合是自己的回合，且本回合发生过「光道」卡片效果从自己卡组送墓
function c83725008.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合，且自己本回合有「光道」卡片效果从卡组送墓的记录
	return tp==Duel.GetTurnPlayer() and c83725008[tp]
end
-- 效果发动目标：设置回复自己500基本分和给与对方500分伤害的操作信息
function c83725008.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：自己回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	-- 设置操作信息：给与对方500分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果运行空间：检查自身状态，并执行回复自己500基本分和给与对方500分伤害的处理
function c83725008.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 自己回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
	-- 给与对方基本分500分伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
