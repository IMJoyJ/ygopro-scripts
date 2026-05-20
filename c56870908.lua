--Yum☆Yum☆ヤミーズ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：每次自己场上有「味美喵」怪兽2只以上同时特殊召唤，自己回复500基本分，对方支付500基本分。
-- ②：支付500基本分，以包含「味美喵★点心抓取猫」的场上2只表侧表示怪兽为对象才能发动。那2只送去墓地，从额外卡组把1只「味美喵」同调怪兽当作同调召唤作特殊召唤。
-- ③：对方把效果发动的场合，支付100基本分才能发动。进行1只「味美喵」连接怪兽的连接召唤。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的所有效果
function s.initial_effect(c)
	-- 将「味美喵★点心抓取猫」的卡片密码加入该卡的关联卡片列表中
	aux.AddCodeList(c,30581601)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次自己场上有「味美喵」怪兽2只以上同时特殊召唤，自己回复500基本分，对方支付500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	-- ②：支付500基本分，以包含「味美喵★点心抓取猫」的场上2只表侧表示怪兽为对象才能发动。那2只送去墓地，从额外卡组把1只「味美喵」同调怪兽当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：对方把效果发动的场合，支付100基本分才能发动。进行1只「味美喵」连接怪兽的连接召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"连接召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetCost(s.spcost2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「味美喵」怪兽
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1ca) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有2只以上的「味美喵」怪兽同时特殊召唤成功
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,2,nil,tp)
end
-- ①效果的处理：自己回复500基本分，对方支付500基本分
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显示该卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 检查自己是否成功回复基本分，且对方基本分是否在500以上
	if Duel.Recover(tp,500,REASON_EFFECT)~=0 and Duel.GetLP(1-tp)>=500 then
		-- 扣除对方500基本分
		Duel.PayLPCost(1-tp,500)
	end
end
-- ②效果的Cost：支付500基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除自己500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：场上表侧表示、可以成为效果对象且能送去墓地的怪兽
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsAbleToGrave()
end
-- 过滤条件：选取的2只怪兽中必须包含「味美喵★点心抓取猫」，且额外卡组存在可特殊召唤的「味美喵」同调怪兽
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsCode,1,nil,30581601)
		-- 检查额外卡组是否存在满足特殊召唤条件的「味美喵」同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 过滤条件：额外卡组的「味美喵」同调怪兽，且在送去墓地2只怪兽后有足够的额外怪兽区域可以特殊召唤
function s.spfilter(c,e,tp,sg)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查在选定的怪兽送去墓地后，额外怪兽区域是否有空位用于特殊召唤该同调怪兽
		and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
-- ②效果的发动准备：选择场上包含「味美喵★点心抓取猫」的2只表侧表示怪兽为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有满足送去墓地条件的表侧表示怪兽
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,2,e,tp)
		-- 检查是否存在必须作为同调素材的限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选取的2只怪兽设为效果对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将这2只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,2,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：将对象怪兽送去墓地，并从额外卡组将1只「味美喵」同调怪兽当作同调召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的效果对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()~=2 then return end
	-- 检查是否成功将2只对象怪兽送去墓地，且它们都在墓地，并满足同调素材限制
	if Duel.SendtoGrave(tg,REASON_EFFECT)==2 and tg:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「味美喵」同调怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		local tc=g:GetFirst()
		if tc then
			tc:SetMaterial(nil)
			-- 将选定的怪兽当作同调召唤特殊召唤到场上
			if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- ③效果的发动条件：对方发动了效果
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ③效果的Cost：支付100基本分
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付100基本分
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 扣除自己100基本分
	Duel.PayLPCost(tp,100)
end
-- 过滤条件：可以进行连接召唤的「味美喵」连接怪兽
function s.spfilter2(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x1ca)
end
-- ③效果的发动准备：检查额外卡组是否存在可连接召唤的「味美喵」连接怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以进行连接召唤的「味美喵」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果的处理：进行1只「味美喵」连接怪兽的连接召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只可以进行连接召唤的「味美喵」连接怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 如果存在可召唤的怪兽，则对其进行连接召唤
	if tc then Duel.LinkSummon(tp,tc,nil) end
end
