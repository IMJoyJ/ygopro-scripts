--聖天樹の月桂精
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ②：把自己场上1只怪兽解放，以「圣天树之月桂精」以外的自己墓地2只植物族连接怪兽为对象才能发动。那些怪兽回到额外卡组。
function c7984540.initial_effect(c)
	-- 添加连接召唤手续，需要2只植物族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只怪兽解放，以「圣天树之月桂精」以外的自己墓地2只植物族连接怪兽为对象才能发动。那些怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7984540,0))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,7984540)
	e2:SetCost(c7984540.tdcost)
	e2:SetTarget(c7984540.tdtg)
	e2:SetOperation(c7984540.tdop)
	c:RegisterEffect(e2)
end
-- ②效果的发动代价（Cost）处理函数：解放自己场上1只怪兽
function c7984540.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：自己墓地「圣天树之月桂精」以外的植物族连接怪兽，且能回到额外卡组
function c7984540.tdfilter(c)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and not c:IsCode(7984540) and c:IsAbleToExtra()
end
-- ②效果的发动准备（Target）处理函数：选择自己墓地2只符合条件的植物族连接怪兽作为效果对象，并声明回到额外卡组的操作信息
function c7984540.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c7984540.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少2只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c7984540.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送提示信息，提示选择要回到额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(7984540,1))  --"请选择要回到额外卡组的卡"
	-- 选择自己墓地2只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7984540.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息，表示该效果包含将选中的卡片送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- ②效果的效果处理（Operation）函数：将作为效果对象的怪兽回到额外卡组
function c7984540.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍受此效果影响的对象卡片送回额外卡组
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
