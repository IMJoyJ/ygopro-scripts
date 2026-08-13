--封印されしエクゾディア
-- 效果：
-- 这张卡和「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」在手卡全部齐集时，自己决斗胜利。
function c33396948.initial_effect(c)
	-- 这张卡和「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」在手卡全部齐集时，自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c33396948.operation)
	c:RegisterEffect(e1)
end
-- 筛选出卡号属于艾克佐迪亚五组件（被封印者的右足8124921、被封印者的左足44519536、被封印者的右腕70903634、被封印者的左腕7902349以及本卡33396948）的卡片。
function c33396948.filter(c)
	return c:IsCode(8124921,44519536,70903634,7902349,33396948)
end
-- 遍历传入的卡组，按卡号分别标记艾克佐迪亚的五个部件（右足、左足、右腕、左腕、本卡）是否已出现，用于判断是否五张组件全部齐集。
function c33396948.check(g)
	local a1=false
	local a2=false
	local a3=false
	local a4=false
	local a5=false
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetCode()
		if code==8124921 then a1=true
		elseif code==44519536 then a2=true
		elseif code==70903634 then a3=true
		elseif code==7902349 then a4=true
		elseif code==33396948 then a5=true
		end
		tc=g:GetNext()
	end
	return a1 and a2 and a3 and a4 and a5
end
-- 每当有卡片加入手牌时触发：分别取出本方和对方手牌中的艾克佐迪亚组件并检查是否集齐；若仅本方集齐则本方获得艾克佐迪亚胜利，仅对方集齐则对方胜利，双方同时集齐则宣告平局。
function c33396948.operation(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_EXODIA = 0x10
	-- 取得本方手牌中的全部艾克佐迪亚组件（本方手牌区域，对方位置为0），并筛选出五组件。
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(c33396948.filter,nil)
	-- 取得对方手牌中的全部艾克佐迪亚组件（本方位置为0，对方手牌区域），并筛选出五组件。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND):Filter(c33396948.filter,nil)
	local wtp=c33396948.check(g1)
	local wntp=c33396948.check(g2)
	if wtp and not wntp then
		-- 向对方玩家展示本方手牌中的艾克佐迪亚组件，以确认本方集齐五组件。
		Duel.ConfirmCards(1-tp,g1)
		-- 判定本方玩家以“艾克佐迪亚”的胜利条件获得本场决斗胜利。
		Duel.Win(tp,WIN_REASON_EXODIA)
	elseif not wtp and wntp then
		-- 向本方玩家展示对方手牌中的艾克佐迪亚组件，以确认对方集齐五组件。
		Duel.ConfirmCards(tp,g2)
		-- 判定对方玩家以“艾克佐迪亚”的胜利条件获得本场决斗胜利。
		Duel.Win(1-tp,WIN_REASON_EXODIA)
	elseif wtp and wntp then
		-- 双方同时集齐五组件时，向对方玩家展示本方手牌中的艾克佐迪亚组件。
		Duel.ConfirmCards(1-tp,g1)
		-- 双方同时集齐五组件时，向本方玩家展示对方手牌中的艾克佐迪亚组件。
		Duel.ConfirmCards(tp,g2)
		-- 双方同时集齐五组件时，以“艾克佐迪亚”的胜利条件宣告平局（PLAYER_NONE）。
		Duel.Win(PLAYER_NONE,WIN_REASON_EXODIA)
	end
end
