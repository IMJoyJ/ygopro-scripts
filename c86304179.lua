--運否の天賦羅－EBI
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张卡为对象才能发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：那张卡特殊召唤。
-- ●里：那张卡破坏，自己失去那个灵摆刻度×300基本分。
-- 【怪兽描述】
-- 走进话题火爆的江户前线(EDO－FRONT)。这里的天赋罗不仅尺度之大不用多说，其富有美感的造型还甚至享有「金赋罗」的异名。港内虽然满是最新锐设备和异文化感，却又飘散着莫名感到怀念的醇香，时而劈啪作响的轻快音色令人心都酥炸了。期盼已久的天赋罗，可惜今天因为周边空域要变天的影响而一律不入港……。虽说是运气差，但连这后面的预定也不得不就此取消。正因为满心期待了1年才更感到特别遗憾，不过就这次的应对态度来说，我认为给3颗星是妥当的。
local s,id,o=GetID()
-- 初始化并注册卡片效果
function s.initial_effect(c)
	-- 启用灵摆怪兽的灵摆属性（灵摆召唤及作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以自己的灵摆区域1张卡为对象才能发动。进行1次投掷硬币，那个里表的以下效果适用。●表：那张卡特殊召唤。●里：那张卡破坏，自己失去那个灵摆刻度×300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cotg)
	e1:SetOperation(s.coop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
-- 过滤条件：可以表侧表示特殊召唤的卡片
function s.cofilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 灵摆效果的发动准备：检查并选择自己灵摆区域的一张卡作为对象
function s.cotg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and s.cofilter(chkc,e,tp) end
	-- 检查可行性：自己灵摆区域存在可特殊召唤的卡，且自己场上有空余的怪兽区域
	if chk==0 then return Duel.IsExistingTarget(s.cofilter,tp,LOCATION_PZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己灵摆区域的1张卡作为效果的对象
	Duel.SelectTarget(tp,s.cofilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
end
-- 灵摆效果的处理：投掷1次硬币，根据正反面结果适用特殊召唤或破坏并扣除生命值的效果
function s.coop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 进行1次投掷硬币
	local c1=Duel.TossCoin(tp,1)
	if c1==1 then
		-- 将作为对象的卡片表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif c1==0 then
		-- 破坏作为对象的卡片，并判断是否破坏成功
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 获取玩家当前的生命值
			local lp=Duel.GetLP(tp)
			-- 设置玩家的生命值为扣除该卡片灵摆刻度×300后的数值
			Duel.SetLP(tp,lp-tc:GetCurrentScale()*300)
		end
	end
end
