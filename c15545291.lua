--剛地帝グランマーグ
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。这张卡上级召唤成功时，选择场上盖放的最多2张卡破坏。这张卡把地属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●从卡组抽1张卡。
function c15545291.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15545291,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15545291.otcon)
	e1:SetOperation(c15545291.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡上级召唤成功时，选择场上盖放的最多2张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15545291,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c15545291.descon)
	e3:SetTarget(c15545291.destg)
	e3:SetOperation(c15545291.desop)
	c:RegisterEffect(e3)
	-- 这张卡把地属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c15545291.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 筛选场上以‘上级召唤’方式召唤成功的怪兽，作为此卡上级召唤时的解放候选。
function c15545291.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 召唤规则效果的可用条件：判断此卡是否满足‘解放1只上级召唤过的怪兽’来进行上级召唤的条件（等级≥7、最多解放1只且存在符合条件的祭品）。
function c15545291.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有‘上级召唤成功过的怪兽’作为可能用于解放的候选组。
	local mg=Duel.GetMatchingGroup(c15545291.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判定此卡等级是否在7星以上、解放数量要求是否≤1，以及候选组中是否有足够1只的祭品可用。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤手续：从候选组中由玩家选择1只怪兽作为解放素材，将其设为素材并解放，完成召唤解放。
function c15545291.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有‘上级召唤成功过的怪兽’作为解放选择候选组。
	local mg=Duel.GetMatchingGroup(c15545291.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家从候选组中选择1只怪兽作为此次上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将所选怪兽以‘召唤’和‘素材’的理由解放。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的触发条件：此卡以‘上级召唤’方式召唤成功时才发动。
function c15545291.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选场上里侧表示（盖放）的卡作为可被选择为破坏对象的卡。
function c15545291.desfilter(c)
	return c:IsFacedown()
end
-- 破坏效果的目标设定：从双方场上选择1~2张里侧表示的卡作为对象；若素材中包含地属性怪兽，则额外设置抽1张卡的操作信息。
function c15545291.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c15545291.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示‘请选择要破坏的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1~2张里侧表示的卡作为破坏对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c15545291.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置本次连锁的破坏操作信息：对象为已选择的对象卡，数量为实际选择数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		-- 设置抽卡操作信息：由当前玩家抽1张卡，供后续效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 处理时过滤对象：筛选仍为里侧表示且与当前效果相关的卡，用于确认破坏对象是否仍然适用。
function c15545291.dfilter(c,e)
	return c:IsFacedown() and c:IsRelateToEffect(e)
end
-- 破坏效果的处理：先将仍为里侧表示且相关的对象卡破坏；若本效果附加了抽卡效果，则另开时点抽1张卡。
function c15545291.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从本次连锁的对象中取出仍为里侧表示且与效果相关的卡，作为实际破坏的卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c15545291.dfilter,nil,e)
	if g:GetCount()>0 then
		-- 以‘效果’为原因破坏选中的卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:GetLabel()==1 then
		-- 中断当前效果，使后续抽卡与破坏不在同一时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 以‘效果’为原因让当前玩家抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 素材检查：若此次上级召唤使用的解放素材中存在地属性怪兽，则将破坏效果的标签设为1，使其处理时追加抽卡；否则设为0。
function c15545291.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
