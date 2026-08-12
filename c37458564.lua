--サイバース・コントラクト・ウィッチ
-- 效果：
-- 相同种族的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合或者这张卡所连接区有怪兽特殊召唤的场合，从自己的手卡·场上（表侧表示）把1张魔法卡送去墓地才能发动。从卡组把1只仪式怪兽加入手卡。
-- ②：以这张卡所连接区1只仪式·融合·同调·超量怪兽为对象才能发动。和那只怪兽是种类（仪式·融合·同调·超量）不同并是种族相同的1只怪兽从自己墓地特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①连接召唤成功或所连接区有怪兽特召时，将手卡/场上一张魔法卡送墓，检索仪式怪兽；②以所连接区1只特殊怪兽为对象，从墓地特召1只与其种族相同但怪兽种类不同的仪式/融合/同调/超量怪兽
function s.initial_effect(c)
	-- 添加连接召唤手续：相同种族的怪兽2只
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合或者这张卡所连接区有怪兽特殊召唤的场合，从自己的手卡·场上（表侧表示）把1张魔法卡送去墓地才能发动。从卡组把1只仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索仪式怪兽"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.thcon2)
	c:RegisterEffect(e2)
	-- ②：以这张卡所连接区1只仪式·融合·同调·超量怪兽为对象才能发动。和那只怪兽是种类（仪式·融合·同调·超量）不同并是种族相同的1只怪兽从自己墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接素材的校验函数
function s.lcheck(g)
	-- 检查用于连接召唤的怪兽是否为相同种族
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 检查此卡是否是通过连接召唤方式特殊召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：是否是在此卡的所连接区特殊召唤的怪兽
function s.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 检查是否有怪兽在此卡的所连接区特殊召唤
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,e:GetHandler())
end
-- 过滤条件：手卡或场上表侧表示的魔法卡，且能送去墓地
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果1的Cost处理：从自己的手卡·场上（表侧表示）把1张魔法卡送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可用于发动Cost的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡或场上表侧表示的1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的魔法卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中的仪式怪兽，且能加入手卡
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果1的靶点筛选与操作信息注册：确认卡组存在仪式怪兽，并声明检索卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1只怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的实际处理：从卡组检索1只仪式怪兽并向对方玩家确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的仪式怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：所连接区的表侧表示的仪式/融合/同调/超量怪兽，且自己墓地存在符合特召条件的同种族且不同类型的怪兽
function s.cfilter2(c,e,tp,lg)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL) and lg:IsContains(c)
		-- 检查墓地中是否存在与该怪兽种族相同但怪兽种类（仪式/融合/同调/超量）不同的仪式/融合/同调/超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetRace(),c:GetType())
end
-- 过滤条件：墓地中与目标怪兽种族相同但卡片类型（仪式/融合/同调/超量）不同，且能特殊召唤的怪兽
function s.spfilter(c,e,tp,rac,type)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL)
		and c:GetType()&type&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL)==0
		and c:IsRace(rac)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备与对象选择：确认自己场上有空余怪兽区域且所连接区存在符合条件的目标，并将目标注册为效果对象，同时声明特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter2(chkc,e,tp,lg) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为效果对象的所连接区仪式/融合/同调/超量怪兽
		and Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,lg) end
	-- 向玩家提示选择效果指向的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择所连接区的1只符合条件的特殊怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,lg)
	-- 设置操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果2 of the actual process: 获取对象怪兽，在确认格子和卡片合法后，选择墓地中种族相同且类型不同的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁所指向的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsFacedown() then return end
	-- 如果当前没有可用的怪兽区域则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只与对象怪兽种族相同但类型不同、且不受「王家长眠之谷」影响的怪兽
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetRace(),tc:GetType()):GetFirst()
	if sc then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
