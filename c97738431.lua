--ナンバーズ・オーバーレイ・ブースト
-- 效果：
-- 选择自己场上1只没有超量素材的名字带有「No.」的超量怪兽才能发动。把自己手卡2只怪兽在选择的超量怪兽下面重叠作为超量素材。
function c97738431.initial_effect(c)
	-- 选择自己场上1只没有超量素材的名字带有「No.」的超量怪兽才能发动。把自己手卡2只怪兽在选择的超量怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c97738431.target)
	e1:SetOperation(c97738431.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、没有超量素材的「No.」超量怪兽
function c97738431.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:GetOverlayCount()==0
end
-- 过滤手卡中可以作为超量素材的怪兽卡
function c97738431.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果发动时的对象合法性检查与可行性判断
function c97738431.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c97738431.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的「No.」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c97738431.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己手卡中是否存在至少2只可以作为超量素材的怪兽
		and Duel.IsExistingMatchingCard(c97738431.matfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 设置选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的「No.」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c97738431.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将手卡2只怪兽重叠在作为对象的超量怪兽下方作为超量素材
function c97738431.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的超量怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 设置选择超量素材的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 获取手卡中所有可以作为超量素材的怪兽卡
		local g=Duel.GetMatchingGroup(c97738431.matfilter,tp,LOCATION_HAND,0,nil)
		if g:GetCount()>=2 then
			local og=g:Select(tp,2,2,nil)
			-- 将选中的手卡怪兽重叠在目标超量怪兽下方作为超量素材
			Duel.Overlay(tc,og)
		end
	end
end
