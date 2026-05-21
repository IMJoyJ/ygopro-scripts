--傷炎星－ウルブショウ
-- 效果：
-- 这张卡反转的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。用反转召唤反转的场合，可以再从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
function c93294869.initial_effect(c)
	-- 这张卡反转的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。用反转召唤反转的场合，可以再从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93294869,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FLIP)
	e1:SetTarget(c93294869.settg)
	e1:SetOperation(c93294869.setop)
	c:RegisterEffect(e1)
	-- 用反转召唤反转的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetOperation(c93294869.flipop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中名字带有「炎舞」且可以盖放的陷阱卡
function c93294869.filter1(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 过滤卡组中名字带有「炎舞」且可以盖放的魔法卡
function c93294869.filter2(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果发动的目标过滤与检测。若自身带有反转召唤成功的标记，则将效果的Label设为1并重置标记，否则设为0
function c93294869.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查卡组中是否存在至少1张可以盖放的「炎舞」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93294869.filter1,tp,LOCATION_DECK,0,1,nil) end
	if e:GetHandler():GetFlagEffect(93294869)~=0 then
		e:SetLabel(1)
		e:GetHandler():ResetFlagEffect(93294869)
	else
		e:SetLabel(0)
	end
end
-- 效果处理。首先从卡组选择1张「炎舞」陷阱卡在场上盖放。若满足反转召唤的条件，可再从卡组选择1张「炎舞」魔法卡在场上盖放
function c93294869.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要盖放卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「炎舞」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c93294869.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择并盖放了「炎舞」陷阱卡，则继续进行后续处理
	if g:GetCount()>0 and Duel.SSet(tp,g)~=0 then
		-- 获取卡组中所有满足条件的「炎舞」魔法卡
		local sg=Duel.GetMatchingGroup(c93294869.filter2,tp,LOCATION_DECK,0,nil)
		-- 若此卡是通过反转召唤反转（Label为1），且卡组中存在可盖放的「炎舞」魔法卡，询问玩家是否进行追加盖放
		if e:GetLabel()==1 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(93294869,1)) then  --"是否要选择名字带有「炎舞」的魔法卡在自己场上盖放？"
			-- 中断当前效果，使后续的盖放处理与之前的盖放不视为同时处理
			Duel.BreakEffect()
			-- 向玩家发送选择要盖放卡片的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选择的「炎舞」魔法卡在自己场上盖放
			Duel.SSet(tp,tg)
		end
	end
end
-- 反转召唤成功时，给自身注册一个临时的Flag标记，用于后续判断是否是通过反转召唤反转
function c93294869.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(93294869,RESET_EVENT+RESETS_STANDARD,0,1)
end
