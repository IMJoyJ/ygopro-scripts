--暗黒界の闘神 ラチナ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时以场上1只恶魔族怪兽为对象。那个场合，再让以下效果适用。
-- ●作为对象的恶魔族怪兽的攻击力上升500。
function c15667446.initial_effect(c)
	-- 效果原文内容：①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时以场上1只恶魔族怪兽为对象。那个场合，再让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15667446,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c15667446.spcon)
	e1:SetTarget(c15667446.sptg)
	e1:SetOperation(c15667446.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断该卡是否从手牌被丢弃到墓地，且不是自己丢弃的（即被对方效果丢弃）
function c15667446.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 规则层面作用：过滤场上正面表示的恶魔族怪兽
function c15667446.atfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 规则层面作用：设置连锁处理时的目标选择和分类，若为对方丢弃则选择一只恶魔族怪兽并设置攻击力上升效果
function c15667446.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15667446.atfilter(chkc) end
	if chk==0 then return true end
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 规则层面作用：提示玩家选择一张正面表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 规则层面作用：选择场上一只正面表示的恶魔族怪兽作为目标
		Duel.SelectTarget(tp,c15667446.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	-- 规则层面作用：设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行特殊召唤并为被选中的恶魔族怪兽增加500攻击力
function c15667446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断此卡是否还在场上并成功特殊召唤
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 规则层面作用：获取当前连锁处理的目标卡
		local tc=Duel.GetFirstTarget()
		if tc and c15667446.atfilter(tc) and tc:IsRelateToEffect(e) then
			-- 规则层面作用：中断当前效果处理，使后续效果不同时处理
			Duel.BreakEffect()
			-- 效果原文内容：●作为对象的恶魔族怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
