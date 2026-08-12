--Emカップ・トリッカー
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：以自己场上1只「娱乐法师」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
-- ②：自己的额外卡组有卡加入的场合才能发动。从自己的额外卡组（表侧）把1只「娱乐法师」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以场上1只超量怪兽为对象才能发动。那只怪兽1个超量素材取除，这张卡特殊召唤。那之后，场上1只超量怪兽的攻击力下降600。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤与灵摆卡发动规则
	aux.EnablePendulumAttribute(c)
	-- ①：以自己场上1只「娱乐法师」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ovtg)
	e1:SetOperation(s.ovop)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有卡加入的场合才能发动。从自己的额外卡组（表侧）把1只「娱乐法师」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收额外"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ①：这张卡在手卡存在的场合，以场上1只超量怪兽为对象才能发动。那只怪兽1个超量素材取除，这张卡特殊召唤。那之后，场上1只超量怪兽的攻击力下降600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"转移超量素材"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*3)
	e4:SetCondition(s.xyzcon)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「娱乐法师」超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6) and c:IsType(TYPE_XYZ)
end
-- 灵摆效果①的靶向与发动准备函数
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ovfilter(chkc) and chkc~=c end
	-- 检查自己场上是否存在可作为对象的「娱乐法师」超量怪兽，且自身能作为超量素材
	if chk==0 then return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_MZONE,0,1,c) and c:IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「娱乐法师」超量怪兽作为对象
	Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 灵摆效果①的处理函数
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的超量怪兽对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将自身原本拥有的超量素材因规则送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将这张卡重叠作为目标超量怪兽的超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 过滤加入到自己额外卡组的卡片
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
-- 灵摆效果②的发动条件：自己的额外卡组有卡加入的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤额外卡组中表侧表示、可加入手牌的「娱乐法师」灵摆怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果②的发动准备与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组（表侧）是否存在可加入手牌的「娱乐法师」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置将额外卡组的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果②的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从额外卡组（表侧）选择1只「娱乐法师」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示且拥有超量素材的超量怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 怪兽效果①的发动准备与靶向函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在有超量素材的超量怪兽，且自己场上有空余怪兽区域
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只拥有超量素材的超量怪兽作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置特殊召唤这张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤场上表侧表示的超量怪兽
function s.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 怪兽效果①的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:GetOverlayCount()>0 and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)~=0
		-- 检查这张卡是否仍与效果相关，并将其以表侧表示特殊召唤
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择场上表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家选择场上1只表侧表示的超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			-- 选中该怪兽并显示选择动画
			Duel.HintSelection(g)
			-- 中断当前效果处理，使后续的攻击力下降处理不与特殊召唤同时进行
			Duel.BreakEffect()
			local dc=g:GetFirst()
			-- 那之后，场上1只超量怪兽的攻击力下降600。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			dc:RegisterEffect(e1)
		end
	end
end
-- 怪兽效果②的发动条件：作为超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤自己场上表侧表示且能成为效果对象的超量怪兽
function s.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
-- 检查选中的2只超量怪兽中，是否至少有1只拥有超量素材
function s.gcheck(g)
	return g:IsExists(s.xyzfilter2,1,nil)
end
-- 过滤自己场上表侧表示且拥有至少1个超量素材的超量怪兽
function s.xyzfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():GetCount()>0
end
-- 怪兽效果②的发动准备与靶向函数
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有可作为对象的超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将选中的2只超量怪兽设为效果的对象
	Duel.SetTargetCard(sg)
end
-- 怪兽效果②的处理函数
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 or not tg:IsExists(s.xyzfilter2,1,nil) then return end
	-- 提示玩家选择失去超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))  --"请选择失去超量素材的怪兽"
	local tg2=tg:FilterSelect(tp,s.xyzfilter2,1,1,nil)
	tg:Sub(tg2)
	local tc=tg2:GetFirst()
	local tc2=tg:GetFirst()
	if tc2 and not tc2:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		local sg=og:Select(tp,1,1,nil)
		-- 将选中的超量素材转移重叠到另一只超量怪兽上
		Duel.Overlay(tc2,sg,false)
		local oc=sg:GetFirst():GetOverlayTarget()
		-- 触发失去超量素材的单体时点
		Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 触发失去超量素材的全局时点
		Duel.RaiseEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
