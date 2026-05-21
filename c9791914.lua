--白銀のスナイパー
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡被对方的卡的效果破坏送去墓地的回合的结束阶段时，这张卡从墓地特殊召唤，选择对方场上1张卡破坏。
function c9791914.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡被对方的卡的效果破坏送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c9791914.regop)
	c:RegisterEffect(e2)
	-- 的回合的结束阶段时，这张卡从墓地特殊召唤，选择对方场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9791914,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(c9791914.sptg)
	e3:SetOperation(c9791914.spop)
	c:RegisterEffect(e3)
end
-- 在送去墓地时，检测是否是在魔陷区盖放状态下被对方卡的效果破坏送墓，若是则注册一个在回合结束时重置的Flag。
function c9791914.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and rp==1-tp then
		c:RegisterFlagEffect(9791914,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
-- 结束阶段特殊召唤并破坏效果的发动准备与目标选择。检查自身是否有Flag，并选择对方场上1张卡作为破坏的对象，设置特殊召唤与破坏的操作信息。
function c9791914.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return e:GetHandler():GetFlagEffect(9791914)>0 end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置当前连锁的操作信息为破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 结束阶段特殊召唤并破坏效果的处理。将自身特殊召唤，若成功则破坏选中的对象。
function c9791914.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否仍与效果相关，并尝试将自身特殊召唤，若特殊召唤成功则继续处理。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁中选择的对象卡。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 因效果将目标卡片破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
