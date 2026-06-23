--影霊衣の魔剣士 アバンス
-- 效果：
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把「影灵衣魔剑士 阿旺斯」以外的1只「影灵衣」怪兽特殊召唤。
-- ②：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把「影灵衣魔剑士 阿旺斯」以外的1只「影灵衣」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
	-- ③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「影灵衣」怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xb4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动①效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的处理函数，用于计算仪式召唤等级
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取当前卡片等级并进行安全阈值处理
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	if c:IsSetCard(0xb4) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- ③效果发动条件判断
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0
end
-- 过滤函数，用于筛选除外状态的「影灵衣」卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4) and c:IsAbleToHand()
end
-- 判断是否可以发动③效果
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断除外区是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁操作信息，提示将要回收卡牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- ③效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外区所有符合条件的卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的卡中选择若干张不重复卡名的卡
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,g:GetCount())
	if tg and tg:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
