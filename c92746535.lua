--竜剣士ラスターP
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，另一边的自己的灵摆区域有卡存在的场合才能发动。那张卡破坏，那1张同名卡从卡组加入手卡。
-- 【怪兽效果】
-- 不能用这张卡为素材把「龙剑士」怪兽以外的融合·同调·超量怪兽特殊召唤。
function c92746535.initial_effect(c)
	-- 注册灵摆怪兽的基本属性（包括灵摆召唤和将灵摆卡在灵摆区域发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有卡存在的场合才能发动。那张卡破坏，那1张同名卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c92746535.thcon)
	e2:SetTarget(c92746535.thtg)
	e2:SetOperation(c92746535.thop)
	c:RegisterEffect(e2)
	-- 不能用这张卡为素材把「龙剑士」怪兽以外的融合·同调·超量怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c92746535.splimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
end
-- 定义灵摆效果的发动条件
function c92746535.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除自身外，自己的灵摆区域是否存在至少1张卡
	return Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：卡组中与被破坏卡片同名的可加入手牌的卡
function c92746535.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 定义灵摆效果的发动（Target）处理
function c92746535.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己另一边灵摆区域的卡
	local sc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,e:GetHandler())
	-- 检查卡组中是否存在另一边灵摆区域卡片的同名卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92746535.thfilter,tp,LOCATION_DECK,0,1,nil,sc:GetOriginalCode()) end
	-- 将另一边灵摆区域的卡设为效果处理的对象
	Duel.SetTargetCard(sc)
	-- 设置操作信息：破坏该对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sc,1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义灵摆效果的效果处理（Operation）
function c92746535.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的另一边灵摆区域的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍适用此效果，则将其因效果破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张被破坏卡片的同名卡
		local g=Duel.SelectMatchingCard(tp,c92746535.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalCode())
		if g:GetCount()>0 then
			-- 将选中的同名卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 限制素材的怪兽判定：不能作为「龙剑士」以外怪兽的特殊召唤素材
function c92746535.splimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xc7)
end
