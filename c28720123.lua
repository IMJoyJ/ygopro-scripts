--竜剣士ダイナマイトP
-- 效果：
-- ←6 【灵摆】 6→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以另一边的自己的灵摆区域1张「龙剑士」卡或「雾动机龙」卡为对象才能发动。那张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「雾动机龙」卡使用。这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡被解放的场合才能发动。除「龙剑士 雾动轰·输力」外的1只「龙剑士」灵摆怪兽或「雾动机龙」灵摆怪兽从自己的额外卡组（表侧）加入手卡。
function c28720123.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基础属性：使其可以作为灵摆卡发动，并能进行灵摆召唤（同时登记灵摆召唤的规则效果）。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果：这个卡名的灵摆效果1回合只能使用1次。①：以另一边的自己的灵摆区域1张「龙剑士」卡或「雾动机龙」卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28720123)
	e1:SetTarget(c28720123.sptg)
	e1:SetOperation(c28720123.spop)
	c:RegisterEffect(e1)
	-- 对应怪兽效果：这个卡名的怪兽效果1回合只能使用1次。①：这张卡被解放的场合才能发动。除「龙剑士 雾动轰·输力」外的1只「龙剑士」灵摆怪兽或「雾动机龙」灵摆怪兽从自己的额外卡组（表侧）加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,28720124)
	e2:SetTarget(c28720123.thtg)
	e2:SetOperation(c28720123.thop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤对象筛选条件：该卡属于「龙剑士」或「雾动机龙」系列，且能被当前效果特殊召唤（检查召唤条件和苏生限制）。
function c28720123.spfilter(c,e,tp)
	return c:IsSetCard(0xc7,0xd8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该效果发动时的取对象判定：对象必须在自己灵摆区、不是这张卡自身、且满足spfilter；在效果发动时（chk==0）还需要确认己方怪兽区有空位且存在合法对象。
function c28720123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and chkc~=c and c28720123.spfilter(chkc,e,tp) end
	-- 在效果发动时（chk==0）检查自己主要怪兽区是否有空位，确保特殊召唤可以进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己灵摆区是否存在至少1张满足spfilter条件且不是这张卡本身的卡，可以作为效果对象。
		and Duel.IsExistingTarget(c28720123.spfilter,tp,LOCATION_PZONE,0,1,c,e,tp) end
	-- 向操作玩家发出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的灵摆区选择1张满足spfilter条件且不是这张卡本身的「龙剑士」或「雾动机龙」卡，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c28720123.spfilter,tp,LOCATION_PZONE,0,1,1,c,e,tp)
	-- 设置本次连锁的操作信息：将进行1张卡的特殊召唤，供相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象卡仍与该效果有联系（未离场或未被无效），则将其特殊召唤到己方场上。
function c28720123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到己方场上（不无视召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义加入手卡效果的筛选条件：属于「龙剑士」或「雾动机龙」系列、不是这张卡自身、是灵摆怪兽且表侧表示、并且可以被加入手卡。
function c28720123.thfilter(c)
	return c:IsSetCard(0xc7,0xd8) and not c:IsCode(28720123) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
-- 回手牌效果的发动条件与操作信息设置：若额外卡组存在符合条件的表侧灵摆怪兽，则设置将1张卡从额外卡组加入手卡。
function c28720123.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）确认自己的额外卡组存在至少1张符合条件的表侧灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28720123.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置本次连锁的操作信息：将要从额外卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择1张符合条件的表侧灵摆怪兽加入持有者手卡，并向对方展示。
function c28720123.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组选择1张符合条件的表侧灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c28720123.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡（nil表示回到持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
