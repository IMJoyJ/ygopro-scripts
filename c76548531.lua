--ゴルゴニック・アンブラル
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌特召·检索效果、②额外卡组特召限制效果、③作为2只超量素材效果
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合，或者只有「阴影」怪兽的场合才能发动。这张卡从手牌特殊召唤。那之后，可以从卡组把1只岩石族以外的「阴影」怪兽加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己从额外卡组只能特殊召唤「No.」超量怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ③：要将需要怪兽3只以上为素材的「No.」超量怪兽超量召唤的场合，这张卡可以作为2只分量的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+o)
	c:RegisterEffect(e3)
end
-- 过滤条件：非表侧表示卡片或非「阴影」卡片
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x87)
end
-- ①效果发动条件：自己场上不存在非表侧表示或非「阴影」卡片
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在非表侧表示或非「阴影」卡片
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 卡组检索过滤条件：非岩石族的「阴影」怪兽且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x87) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- ①效果发动准备：设置特殊召唤自身及检索卡片的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动条件检查：卡组是否存在满足条件的非岩石族「阴影」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：特殊召唤自身，成功时可从卡组把1只非岩石族的「阴影」怪兽加入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且成功特殊召唤到场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组是否存在可加入手牌的非岩石族「阴影」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		-- 显示选择加入手牌卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足条件的非岩石族「阴影」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 特殊召唤限制过滤：禁止从额外卡组特殊召唤非「No.」超量怪兽
function s.splimit(e,c)
	return not (c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 超量素材过滤：判断超量怪兽是否为「No.」超量怪兽
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
