--クロノダイバー・フライバック
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从手卡·卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。
-- ②：把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。
function c18678554.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从手卡·卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18678554,0))  --"自己的卡作为超量素材"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18678554)
	e1:SetTarget(c18678554.target)
	e1:SetOperation(c18678554.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18678554,1))  --"对方的卡作为超量素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,18678554)
	-- 为②效果设定发动COST：把墓地的这张卡除外（aux.bfgcost标准代价函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c18678554.mattg)
	e2:SetOperation(c18678554.matop)
	c:RegisterEffect(e2)
end
-- 定义「时间潜行者」超量怪兽的筛选条件：表侧表示、超量怪兽且属于0x126字段。
function c18678554.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x126)
end
-- 定义可叠放素材的筛选条件：属于「时间潜行者」字段且可以作为超量素材。
function c18678554.matfilter(c)
	return c:IsSetCard(0x126) and c:IsCanOverlay()
end
-- ①效果的发动条件合法性检查部分：在chk==0时判断是否存在可取对象及手卡/卡组中可叠放素材，同时处理连锁中指定对象的chkc合法性校验。
function c18678554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18678554.xyzfilter(chkc) end
	-- 合法性检查：自己场上是否存在1只表侧表示的「时间潜行者」超量怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 合法性检查：手卡或卡组中是否存在1张「时间潜行者」卡可以作为超量素材叠放。
		and Duel.IsExistingMatchingCard(c18678554.matfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 向玩家发出选择对象的提示信息（显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「时间潜行者」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果结算处理：取得对象怪兽，若对象仍与效果关联且不免疫该效果，则从手卡或卡组选1张「时间潜行者」卡叠放在对象下方作为超量素材。
function c18678554.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时已选定的对象怪兽（唯一的取对象目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 发出选择超量素材的提示信息（显示“请选择要作为超量素材的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手卡或卡组选择1张可作为超量素材的「时间潜行者」卡。
		local g=Duel.SelectMatchingCard(tp,c18678554.matfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tc)
		if g:GetCount()>0 then
			-- 将选择的卡作为超量素材叠放在对象超量怪兽下方。
			Duel.Overlay(tc,g)
		end
	end
end
-- ②效果的发动条件合法性检查部分：在chk==0时判断是否存在可取对象及对方墓地可叠放素材，同时处理连锁中指定对象的chkc合法性校验。
function c18678554.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18678554.xyzfilter(chkc) end
	-- 合法性检查：自己场上是否存在1只表侧表示的「时间潜行者」超量怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 合法性检查：对方墓地是否存在1张可以作为超量素材的卡。
		and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发出选择对象的提示信息（显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「时间潜行者」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果结算处理：取得对象怪兽，若对象仍与效果关联且不免疫该效果，则从对方墓地选1张卡叠放在对象下方作为超量素材；处理前检查王家长眠之谷。
function c18678554.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时已选定的对象怪兽（唯一的取对象目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 发出选择超量素材的提示信息（显示“请选择要作为超量素材的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 获取对方墓地的全部卡（作为备选素材组）。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
		-- 检查对方墓地卡片是否受王家长眠之谷效果影响，若是则本次②效果被无效并直接结束处理。
		if aux.NecroValleyNegateCheck(g) then return end
		local tg=g:FilterSelect(tp,Card.IsCanOverlay,1,1,nil)
		if #tg>0 then
			-- 将选出的对方墓地卡片作为超量素材叠放在对象超量怪兽下方。
			Duel.Overlay(tc,tg)
		end
	end
end
