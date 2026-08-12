--蒼の深淵 ディープアイズ・ホワイト・ドラゴン
-- 效果：
-- 这个卡名在规则上也当作「青眼」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1只光属性·1星调整加入手卡。
-- ②：「青眼」仪式怪兽或「青眼白龙」被送去自己墓地的场合，以那之内的1只为对象才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡攻击力变成和作为对象的怪兽相同，从场上离开的场合除外。
local s,id,o=GetID()
-- 注册「苍之深渊 渊眼白龙」效果的 initial_effect 函数
function s.initial_effect(c)
	-- 记录卡片记有「青眼白龙」卡名的事实
	aux.AddCodeList(c,89631139)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1只光属性·1星调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 合并并监听自己墓地中是否有特定卡片被送墓的事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ②：「青眼」仪式怪兽或「青眼白龙」被送去自己墓地的场合，以那之内的1只为对象才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡攻击力变成和作为对象的怪兽相同，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①（手卡丢弃检索光属性1星调整）的发动cost检测与执行函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡从手卡丢弃送去墓地作为发动的cost
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤可以加入手卡的光属性1星调整怪兽的条件过滤函数
function s.thfilter(c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果①的发动准备与检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查卡组是否存在可以加入手卡的光属性1星调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只光属性1星调整怪兽
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将所选怪兽加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤被送去自己墓地的「青眼」仪式怪兽或「青眼白龙」
function s.cfilter(c,tp)
	return (c:IsSetCard(0xdd) and c:IsType(TYPE_RITUAL) or c:IsCode(89631139))
		and c:GetOwner()==tp
end
-- 效果②（特定怪兽送墓时特召自身）的发动条件检测函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤留在墓地且可以被指定为效果对象的卡片
function s.tgfilter(c,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动准备与检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e)
	if chkc then return mg:IsContains(chkc) and s.tgfilter(chkc,e) end
	if chk==0 then return mg:GetCount()>0
		-- 发动时，检查自己场上的怪兽区域是否有可用的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 把作为效果对象的怪兽设为当前连锁的目标卡片
	Duel.SetTargetCard(g)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果所指定的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果处理时，检查自身卡片是否在当前区域且不受王家之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将这张卡从手卡或墓地特殊召唤到自己场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if tc and tc:IsRelateToChain() then
			-- 这个效果特殊召唤的这张卡攻击力变成和作为对象的怪兽相同
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
end
