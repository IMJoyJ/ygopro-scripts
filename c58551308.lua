--ダークファミリア
-- 效果：
-- 反转：这张卡被送去墓地时，双方玩家选择各自墓地存在的1只怪兽，表侧攻击表示或者里侧守备表示特殊召唤。
function c58551308.initial_effect(c)
	-- 反转：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c58551308.flipop)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地时，双方玩家选择各自墓地存在的1只怪兽，表侧攻击表示或者里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58551308,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c58551308.sptg)
	e2:SetOperation(c58551308.spop)
	c:RegisterEffect(e2)
end
-- 反转时的操作：若自身在场上或墓地，则给自身注册一个表示已反转的Flag
function c58551308.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) then
		c:RegisterFlagEffect(58551308,RESET_EVENT+0x57a0000,0,1)
	end
end
-- 过滤条件：可以以表侧攻击表示或里侧守备表示特殊召唤的怪兽
function c58551308.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果发动的目标：检查自身是否曾反转，并让双方玩家各选择自己墓地的一只怪兽作为对象
function c58551308.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():GetFlagEffect(58551308)~=0 end
	-- 给回合玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 回合玩家选择自己墓地的一只怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c58551308.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 给对方玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 对方玩家选择自己墓地的一只怪兽作为效果对象
	local g2=Duel.SelectTarget(1-tp,c58551308.filter,1-tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,1-tp)
	g1:Merge(g2)
	-- 设置特殊召唤的操作信息，包含选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,#g1,0,0)
end
-- 效果处理：将双方选择的对象怪兽以表侧攻击表示或里侧守备表示特殊召唤
function c58551308.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==0 then return end
	local tc=sg:GetFirst()
	-- 若第一个对象存在且其持有者的怪兽区域有空位
	if tc and Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE)>0 then
		local sp=tc:GetControler()
		-- 将第一个对象以表侧攻击表示或里侧守备表示特殊召唤，并判断是否为里侧表示
		if Duel.SpecialSummonStep(tc,0,sp,sp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) and tc:IsFacedown() then
			-- 若第一个对象以里侧表示特殊召唤，则向对方玩家确认该卡
			Duel.ConfirmCards(1-sp,tc)
		end
	end
	tc=sg:GetNext()
	-- 若第二个对象存在且其持有者的怪兽区域有空位
	if tc and Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE)>0 then
		local sp=tc:GetControler()
		-- 将第二个对象以表侧攻击表示或里侧守备表示特殊召唤，并判断是否为里侧表示
		if Duel.SpecialSummonStep(tc,0,sp,sp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) and tc:IsFacedown() then
			-- 若第二个对象以里侧表示特殊召唤，则向对方玩家确认该卡
			Duel.ConfirmCards(1-sp,tc)
		end
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
