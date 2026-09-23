--スピリット・オブ・ユベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组选有「于贝尔」的卡名记述的1张魔法·陷阱卡加入手卡或在自己场上盖放。
-- ③：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ④：这张卡被破坏的场合才能发动。自己的手卡·卡组·墓地·除外状态的1只「于贝尔」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 注册记述卡号：记录「于贝尔」(78371393)
	aux.AddCodeList(c,78371393)
	-- 注册记述字段：记录「于贝尔」(0x1a5)怪兽
	aux.AddSetNameMonsterList(c,0x1a5)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组选有「于贝尔」的卡名记述的1张魔法·陷阱卡加入手卡或在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索魔法·陷阱"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡不会被战斗破坏，
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ④：这张卡被破坏的场合才能发动。自己的手卡·卡组·墓地·除外状态的1只「于贝尔」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))  --"特殊召唤「于贝尔」"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)
end
-- 效果发动条件：对方怪兽攻击宣言
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果发动检查与设置操作信息：从手卡特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认怪兽区有空位且自身可以守备表示特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤记述「于贝尔」的魔法·陷阱卡
function s.thfilter(c)
	-- 检查是否为记述「于贝尔」卡名的魔法·陷阱卡
	if not (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,78371393)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 效果发动检查：确认卡组存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在记述「于贝尔」的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：加入手卡或在场上盖放
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张记述「于贝尔」的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 选择加入手卡的分支判断
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡在场上盖放
			Duel.SSet(tp,tc)
		end
	end
end
-- 过滤卡名为「于贝尔」的怪兽
function s.filter2(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(78371393) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果发动检查与设置操作信息：特殊召唤「于贝尔」
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认怪兽区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡·卡组·墓地·除外区存在「于贝尔」
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：从手卡·卡组·墓地·除外状态特殊召唤「于贝尔」
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只「于贝尔」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		-- 若从卡组特殊召唤则洗切卡组
		Duel.ShuffleDeck(tp)
	end
end
