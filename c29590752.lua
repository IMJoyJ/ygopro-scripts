--剣闘獣オクタビウス
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，把魔法与陷阱卡区域盖放的1张卡破坏。这张卡进行战斗的自己的战斗阶段结束时，丢弃1张手卡或这张卡回到卡组。
function c29590752.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，把魔法与陷阱卡区域盖放的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29590752,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 判断是否为通过「剑斗兽」怪兽的效果特殊召唤
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c29590752.destg)
	e1:SetOperation(c29590752.desop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的自己的战斗阶段结束时，丢弃1张手卡或这张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29590752,1))  --"丢手卡或回卡组"
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c29590752.dcon)
	e2:SetTarget(c29590752.dtg)
	e2:SetOperation(c29590752.dop)
	c:RegisterEffect(e2)
end
-- 破坏效果的过滤条件：卡片必须是盖放且不在场地区域
function c29590752.desfilter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 设置破坏效果的目标选择函数，用于选择魔法与陷阱区域的盖放卡片
function c29590752.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c29590752.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡片：从魔法与陷阱区域选择1张盖放的卡
	local g=Duel.SelectTarget(tp,c29590752.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：将要破坏的卡加入连锁处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果的操作函数
function c29590752.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足丢弃手卡或回卡组效果的发动条件
function c29590752.dcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前卡已参与战斗且为当前回合玩家
	return e:GetHandler():GetBattledGroupCount()>0 and Duel.GetTurnPlayer()==tp
end
-- 设置丢弃手卡或回卡组效果的目标选择函数
function c29590752.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(29590753)==0 end
	e:GetHandler():RegisterFlagEffect(29590753,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,EFFECT_FLAG_OATH,1)
	-- 设置操作信息：准备处理丢弃手牌效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,0)
end
-- 执行丢弃手卡或回卡组效果的操作函数
function c29590752.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断是否可以发动丢弃手牌效果：手牌数量大于0且玩家选择丢弃
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.SelectYesNo(tp,aux.Stringid(29590752,2)) then  --"丢弃一张手牌吗？"
		-- 丢弃1张手牌
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	else
		-- 将此卡送回卡组
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
