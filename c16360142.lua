--斬機サブトラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽的攻击力直到回合结束时下降1000。这个效果特殊召唤的回合，这张卡不能攻击。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
function c16360142.initial_effect(c)
	-- 对应效果原文：“这个卡名的效果1回合只能使用1次。①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽的攻击力直到回合结束时下降1000。这个效果特殊召唤的回合，这张卡不能攻击。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,16360142)
	e1:SetTarget(c16360142.sptg)
	e1:SetOperation(c16360142.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定：获取效果来源卡；若为对象合法性检查，则确认对象是场上表侧表示怪兽；在发动时确认此卡可以被特殊召唤、自己场上有空位且存在可选对象。
function c16360142.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有可用的主要怪兽区空位，用于后续将这张卡从手卡特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1只表侧表示怪兽且能成为此效果的对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家弹出选择提示，要求选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上的表侧表示怪兽中选择1只作为效果对象，并登记为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本连锁将进行特殊召唤，目标为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其特殊召唤；若特殊召唤成功，给这张卡附加本回合不能攻击的效果；接着取对象怪兽，若仍关联且表侧表示，则其攻击力下降1000；最后给当前玩家附加本回合只能从额外卡组特殊召唤电子界族怪兽的自肃效果。
function c16360142.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联后，将其从手卡以表侧攻击表示特殊召唤，若特殊召唤成功则进入后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对应效果原文：“这个效果特殊召唤的回合，这张卡不能攻击。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 获取效果发动时选择的作为对象的那只怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 对应效果原文：“作为对象的怪兽的攻击力直到回合结束时下降1000。”
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-1000)
			tc:RegisterEffect(e1)
		end
	end
	-- 对应效果原文：“这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c16360142.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将该自肃效果注册给当前玩家，使其在本回合生效。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的过滤条件：若怪兽位于额外卡组且不是电子界族，则不能将其特殊召唤。
function c16360142.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
