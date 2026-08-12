--音響戦士ギタリス
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1张「音响战士」卡为对象才能发动。那张卡和这张卡回到持有者手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己的场地区域有「音响放大器」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆属性和三个效果
function c43210483.initial_effect(c)
	-- 记录该卡与「音响放大器」的关联
	aux.AddCodeList(c,75304793)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：以这张卡以外的自己场上1张「音响战士」卡为对象才能发动。那张卡和这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43210483,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43210483)
	e1:SetTarget(c43210483.ptg)
	e1:SetOperation(c43210483.pop)
	c:RegisterEffect(e1)
	-- ①：自己的场地区域有「音响放大器」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43210483,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,43210483+o)
	e2:SetCondition(c43210483.spcon)
	e2:SetTarget(c43210483.sptg)
	e2:SetOperation(c43210483.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43210483,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,43210483+o*2)
	e3:SetTarget(c43210483.thtg)
	e3:SetOperation(c43210483.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 定义灵摆效果中可选择的目标卡片过滤条件：必须是「音响战士」卡且在场上正面表示
function c43210483.pfilter(c)
	return c:IsSetCard(0x1066) and c:IsFaceup() and c:IsAbleToHand()
end
-- 设置灵摆效果的目标选择函数，检查目标是否满足过滤条件
function c43210483.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and c43210483.pfilter(chkc) end
	if chk==0 then return c:IsAbleToHand()
		-- 判断是否满足灵摆效果发动条件：自己场上存在符合条件的「音响战士」卡
		and Duel.IsExistingTarget(c43210483.pfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的「音响战士」卡作为目标
	local g=Duel.SelectTarget(tp,c43210483.pfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	-- 设置连锁操作信息：将两张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 执行灵摆效果的处理函数，将目标卡和自身送回手牌
function c43210483.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将目标卡组送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 设置特殊召唤效果的发动条件：场地区域存在「音响放大器」
function c43210483.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地区域是否存在「音响放大器」
	return Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
end
-- 设置特殊召唤效果的目标选择函数，检查是否能特殊召唤自身
function c43210483.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果的处理函数，将自身特殊召唤到场上
function c43210483.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将自身以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置召唤/特殊召唤成功后效果的目标选择函数，选择灵摆区域的卡
function c43210483.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 判断是否满足召唤/特殊召唤成功后效果的发动条件：自己灵摆区域有可返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的灵摆卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择灵摆区域的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置连锁操作信息：将一张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行召唤/特殊召唤成功后效果的处理函数，将目标卡送回手牌
function c43210483.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
