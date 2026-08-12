--宣告者の預言
-- 效果：
-- 「神光之宣告者」的降临必需。必须从手卡·自己场上把等级合计直到6的怪兽解放。这张卡的效果让「神光之宣告者」仪式召唤成功时，可以把自己墓地存在的这张卡从游戏中除外，选择为那次仪式召唤而解放的1只怪兽从自己墓地回到手卡。
function c27383110.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求仪式怪兽为神光之宣告者（卡号44665365），并设置额外处理函数为extraop
	aux.AddRitualProcEqualCode(c,44665365,nil,nil,nil,false,c27383110.extraop)
	-- 「神光之宣告者」的降临必需。必须从手卡·自己场上把等级合计直到6的怪兽解放。这张卡的效果让「神光之宣告者」仪式召唤成功时，可以把自己墓地存在的这张卡从游戏中除外，选择为那次仪式召唤而解放的1只怪兽从自己墓地回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(27383110,0))  --"一只仪式解放的怪兽回到手卡"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+27383110)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c27383110.thcon)
	e2:SetCost(c27383110.thcost)
	e2:SetTarget(c27383110.thtg)
	e2:SetOperation(c27383110.thop)
	c:RegisterEffect(e2)
end
-- 当仪式召唤成功时，将仪式召唤的怪兽信息保存到效果标签中，并注册一个连锁结束时触发的效果
function c27383110.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	e:SetLabelObject(tc)
	-- 注册一个在连锁结束时触发的效果，用于触发自定义事件
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(c27383110.evop)
	e1:SetLabelObject(e)
	-- 将效果e1注册到玩家tp的场上
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前处理的效果是否为该卡自身的效果
function c27383110.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler()
end
-- 检查是否满足发动条件，若满足则将该卡从墓地除外作为代价
function c27383110.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsAbleToRemove() end
	-- 将该卡从游戏中除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义一个过滤器，用于筛选满足条件的墓地中的解放怪兽
function c27383110.thfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsReason(REASON_RELEASE)
		and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 设置选择目标和操作信息，用于选择并处理要返回手牌的解放怪兽
function c27383110.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return mat:IsContains(chkc) and c27383110.thfilter(chkc,e,tp) end
	if chk==0 then return mat:IsExists(c27383110.thfilter,1,nil,e,tp) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=mat:FilterSelect(tp,c27383110.thfilter,1,1,nil,e,tp)
	-- 设置当前效果的目标卡为g
	Duel.SetTargetCard(g)
	-- 设置当前效果的操作信息为将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果操作，将目标卡送回手牌并确认对方查看
function c27383110.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 触发自定义事件，用于通知后续处理
function c27383110.evop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local tc=te:GetLabelObject()
	-- 触发一个自定义事件，用于通知仪式召唤完成后的处理
	Duel.RaiseEvent(tc,EVENT_CUSTOM+27383110,te,0,tp,tp,0)
	te:SetLabelObject(nil)
	e:Reset()
end
