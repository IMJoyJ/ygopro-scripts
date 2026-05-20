--炎の剣域
-- 效果：
-- ①：在自己的战士族·炎属性怪兽的召唤成功时对方不能把卡的效果发动。
-- ②：1回合1次，从自己的手卡·场上（表侧表示）把1只怪兽送去墓地才能发动。从额外卡组把1只「炎之剑士」当作融合召唤作特殊召唤。
-- ③：1回合1次，怪兽的攻击宣言时，以自己场上1只战士族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降1000，那只怪兽以外的自己场上的全部怪兽的攻击力直到回合结束时上升1000。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、当作融合召唤特殊召唤「炎之剑士」、召唤成功时限制对方发动效果、以及攻击宣言时增减怪兽攻击力的效果。
function s.initial_effect(c)
	-- 记录这张卡片上记载了「炎之剑士」的卡名。
	aux.AddCodeList(c,45231177)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己的手卡·场上（表侧表示）把1只怪兽送去墓地才能发动。从额外卡组把1只「炎之剑士」当作融合召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"融合召唤「炎之剑士」"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：在自己的战士族·炎属性怪兽的召唤成功时对方不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.limcon)
	e3:SetOperation(s.limop)
	c:RegisterEffect(e3)
	-- ①：在自己的战士族·炎属性怪兽的召唤成功时对方不能把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
	c:RegisterEffect(e4)
	-- ③：1回合1次，怪兽的攻击宣言时，以自己场上1只战士族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降1000，那只怪兽以外的自己场上的全部怪兽的攻击力直到回合结束时上升1000。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"下降怪兽攻击力并上升其他怪兽攻击力"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.atktg)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
s.fusion_effect=true
-- 过滤手卡或场上表侧表示、能送去墓地且送去墓地后能满足额外卡组特殊召唤「炎之剑士」条件的怪兽。
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
		-- 检查额外卡组是否存在满足特殊召唤条件的「炎之剑士」（传入当前作为Cost送墓的怪兽以进行额外怪兽区域格子检测）。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤效果的发动代价（Cost）处理函数，检查并执行将手卡·场上的怪兽送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查是否满足融合素材的特殊限制规则。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查手卡或场上是否存在可作为Cost送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤额外卡组中可以进行融合召唤且能特殊召唤的「炎之剑士」。
function s.filter(c,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsCode(45231177) and c:CheckFusionMaterial()
		-- 检查该卡是否能以融合召唤的方式特殊召唤，且在送墓怪兽离场后额外怪兽区域是否有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 特殊召唤效果的发动准备（Target）处理函数，进行合法性检测并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then return true end
		e:SetLabel(0)
		-- 检查是否满足融合素材的特殊限制规则。
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
			-- 检查额外卡组是否存在可以特殊召唤的「炎之剑士」。
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	-- 设置连锁处理中的操作信息，表明将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的效果处理（Operation）函数，执行从额外卡组特殊召唤「炎之剑士」的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查是否满足融合素材的特殊限制规则，不满足则不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「炎之剑士」。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽以融合召唤的方式表侧表示特殊召唤。
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 过滤召唤成功的怪兽是否为自己召唤的战士族怪兽。
function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsRace(RACE_WARRIOR)
end
-- 召唤成功时限制对方发动效果的条件函数，检查是否有自己的战士族怪兽召唤成功。
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 召唤成功时限制对方发动效果的处理函数，根据当前连锁数决定是直接限制连锁还是注册延迟限制。
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前没有其他连锁正在处理（即召唤成功时直接进入时点）。
	if Duel.GetCurrentChain()==0 then
		-- 限制对方直到连锁结束前不能发动卡的效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果当前是在连锁1处理完毕后的召唤成功时点（例如通过卡的效果召唤成功）。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己的战士族·炎属性怪兽的召唤成功时对方不能把卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册全局效果，在有新连锁发动时重置限制标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果，在效果处理被中断时重置限制标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置限制标记并使临时注册的重置效果失效。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时的处理函数，如果存在限制标记，则在连锁结束时应用限制对方发动的效果。
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制对方直到连锁结束前不能发动卡的效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 连锁限制的判定函数，限制只有发动玩家自己可以发动效果（即对方不能发动效果）。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤场上表侧表示、战士族且攻击力在1000以上的怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttackAbove(1000)
end
-- 攻击力增减效果的发动准备（Target）处理函数，进行对象选择和合法性检测。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 检查自己场上是否存在满足条件的战士族怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只满足条件的战士族怪兽作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻击力增减效果的效果处理（Operation）函数，使对象怪兽攻击力下降1000，并使其他怪兽攻击力上升1000。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackAbove(1000) then
		-- 那只怪兽的攻击力直到回合结束时下降1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e) and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 获取自己场上除对象怪兽以外的所有表侧表示怪兽。
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,tc)
			local oc=g:GetFirst()
			while oc do
				-- 那只怪兽以外的自己场上的全部怪兽的攻击力直到回合结束时上升1000
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(1000)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				oc:RegisterEffect(e2)
				oc=g:GetNext()
			end
		end
	end
end
