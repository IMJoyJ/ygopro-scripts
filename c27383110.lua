--宣告者の預言
-- 效果：
-- 「神光之宣告者」的降临必需。必须从手卡·自己场上把等级合计直到6的怪兽解放。这张卡的效果让「神光之宣告者」仪式召唤成功时，可以把自己墓地存在的这张卡从游戏中除外，选择为那次仪式召唤而解放的1只怪兽从自己墓地回到手卡。
function c27383110.initial_effect(c)
	-- 为这张卡添加仪式召唤效果（仪式魔法），使「神光之宣告者」降临，必须从手卡·自己场上把等级合计直到6的怪兽解放，并指定extraop作为仪式召唤成功后的追加处理。
	aux.AddRitualProcEqualCode(c,44665365,nil,nil,nil,false,c27383110.extraop)
	-- 可以把自己墓地存在的这张卡从游戏中除外，选择为那次仪式召唤而解放的1只怪兽从自己墓地回到手卡。
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
-- 仪式召唤成功后的追加处理：若存在仪式召唤的怪兽tc，将其暂存在效果e的LabelObject中，同时创建一个仅在连锁结束时生效的持续效果e1，用于在连锁结束后触发后续回手效果的时点。
function c27383110.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	e:SetLabelObject(tc)
	-- 这张卡的效果让「神光之宣告者」仪式召唤成功时
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(c27383110.evop)
	e1:SetLabelObject(e)
	-- 将新创建的持续效果e1注册到tp玩家的场地，使其在连锁结束时执行evop，从而触发自定义事件。
	Duel.RegisterEffect(e1,tp)
end
-- 回手效果的发动条件：当前触发的事件必须是由这张「宣告者的预言」自身的效果（re的handler等于本卡）产生的，即只在该仪式魔法效果让神光之宣告者仪式召唤成功时才能发动。
function c27383110.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler()
end
-- 回手效果的代价函数：在判定时检查本卡是否在墓地且可以除外；支付时调用Duel.Remove除外墓地的这张卡。
function c27383110.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsAbleToRemove() end
	-- 将墓地的这张「宣告者的预言」表侧表示除外，作为发动回手效果的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 筛选符合条件的解放素材：位于墓地、归属我方、因解放而被送去墓地、可以加入手卡且能成为效果对象，用于选择为那次仪式召唤而解放的1只怪兽。
function c27383110.thfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsReason(REASON_RELEASE)
		and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 回手效果的目标选择：获取仪式召唤怪兽及其素材，确认素材中存在至少1只符合筛选条件的解放素材；然后提示玩家选择1张，将其设为效果对象，并登记回手牌的操作信息。
function c27383110.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return mat:IsContains(chkc) and c27383110.thfilter(chkc,e,tp) end
	if chk==0 then return mat:IsExists(c27383110.thfilter,1,nil,e,tp) end
	-- 向玩家显示选择提示“请选择要返回手牌的卡”，用于选择操作时缓存提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=mat:FilterSelect(tp,c27383110.thfilter,1,1,nil,e,tp)
	-- 将选中的解放素材怪兽设置为当前连锁的效果对象，使其与效果建立联系，便于后续判断和取回。
	Duel.SetTargetCard(g)
	-- 登记本连锁的操作信息：将选中的解放素材卡（g）返回手牌（CATEGORY_TOHAND），数量为g的数量，用于给其他卡检测本次效果类型。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 回手效果的实际处理：取得作为对象的目标卡，若目标仍与效果相关，则将其返回手牌，并向对方玩家确认那张卡。
function c27383110.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中通过Duel.SetTargetCard设置的第一个效果对象（即被选择的解放素材怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回其持有者的手卡（nil表示回到持有者手牌），原因是效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示返回手牌的那只怪兽，使对方确认回手的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 延迟处理函数：在连锁结束时，取出之前暂存的仪式效果te及仪式召唤怪兽tc，通过Duel.RaiseEvent触发自定义事件；之后清除暂存并重置临时效果，完成整个回手效果的发动流程。
function c27383110.evop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local tc=te:GetLabelObject()
	-- 以仪式召唤的怪兽tc作为事件对象，触发自定义事件EVENT_CUSTOM+27383110，事件来源为仪式效果te，由tp玩家发出，从而让回手效果的condition得到满足并发动。
	Duel.RaiseEvent(tc,EVENT_CUSTOM+27383110,te,0,tp,tp,0)
	te:SetLabelObject(nil)
	e:Reset()
end
