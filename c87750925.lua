--虚英雄ディスガイス
-- 效果：
-- 自己场上或墓地有装备魔法卡存在的场合：可以把这张卡从手卡特殊召唤。
-- 这张卡召唤·特殊召唤的场合：可以从卡组把1张「咒怨仿品·圣剑」加入手卡。
-- 这张卡有装备卡装备中的场合：可以以场上1只持有等级的调整以外的战士族怪兽为对象；这张卡的等级和卡名直到回合结束时变成和那只怪兽相同。
-- 「效仿英杰 伪装者」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册记载卡名、手牌特召、召·特召成功检索「咒怨仿品·圣剑」以及改变自身卡名等级效果
function s.initial_effect(c)
	-- 注册关联卡片代码：在列表中添加「咒怨仿品·圣剑」(23249029)
	aux.AddCodeList(c,23249029)
	-- 自己场上或墓地有装备魔法卡存在的场合：可以把这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡召唤·特殊召唤的场合：可以从卡组把1张「咒怨仿品·圣剑」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡有装备卡装备中的场合：可以以场上1只持有等级的调整以外的战士族怪兽为对象；这张卡的等级和卡名直到回合结束时变成和那只怪兽相同。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"改变卡名等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.lvcon)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
-- 手牌特召条件卡片过滤：场上或墓地的表侧表示装备魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsFaceupEx()
end
-- 手牌特召发动条件检查：己方场上或墓地存在装备魔法卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上或墓地是否存在满足条件的装备魔法卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 手牌特召效果发动准备：检查怪兽区空位与自身特召可行性并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手牌特召效果处理：将自身从手牌表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索目标卡片过滤：卡组中可加入手牌的「咒怨仿品·圣剑」
function s.thfilter(c)
	return c:IsCode(23249029) and c:IsAbleToHand()
end
-- 检索效果发动准备：检查卡组是否存在目标卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以加入手牌的「咒怨仿品·圣剑」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组把1张「咒怨仿品·圣剑」加入手牌并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「咒怨仿品·圣剑」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 改变卡名等级效果发动条件检查：自身有装备卡装备中
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipCount()>0
end
-- 目标怪兽过滤条件：场上表侧表示、持有等级、非调整的战士族怪兽且等级或卡名与自身不同
function s.lvfilter(c,lv,ec)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsType(TYPE_TUNER) and c:IsRace(RACE_WARRIOR)
		and (not c:IsLevel(lv) or not c:IsCode(ec:GetCode()))
end
-- 改变卡名等级效果发动准备：选择场上1只符合条件的战士族怪兽为对象
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,lv,c) end
	-- 检查场上是否存在可以作为效果对象的符合条件的战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,lv,c) end
	-- 向玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只符合条件的战士族怪兽作为连锁对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,lv,c)
end
-- 改变卡名等级效果处理：直到回合结束时，将自身的等级和卡名变成与目标怪兽相同
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToChain() and c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这张卡的卡名直到回合结束时变成和那只怪兽相同。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetCode())
		c:RegisterEffect(e2)
	end
end
