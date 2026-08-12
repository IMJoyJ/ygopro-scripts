--ユニオン・キャリアー
-- 效果：
-- 种族或者属性相同的怪兽2只
-- 这个卡名的效果1回合只能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组选原本种族或者原本属性和作为对象的怪兽相同的1只怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。这个效果从卡组装备的场合，直到回合结束时自己不能把那张装备的怪兽卡以及那些同名怪兽特殊召唤。
function c83152482.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只怪兽作为素材，并使用自定义过滤函数进行判定
	aux.AddLinkProcedure(c,nil,2,2,c83152482.lcheck)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c83152482.lmlimit)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组选原本种族或者原本属性和作为对象的怪兽相同的1只怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。这个效果从卡组装备的场合，直到回合结束时自己不能把那张装备的怪兽卡以及那些同名怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83152482,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,83152482)
	e2:SetTarget(c83152482.eqtg)
	e2:SetOperation(c83152482.eqop)
	c:RegisterEffect(e2)
end
-- 判定连接素材是否为2只，且原本种族或原本属性相同
function c83152482.lcheck(g,lc)
	if #g<2 then return false end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	return c1:GetLinkAttribute()&c2:GetLinkAttribute()>0 or c1:GetLinkRace()&c2:GetLinkRace()>0
end
-- 判定自身是否处于连接召唤的回合
function c83152482.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤自己场上表侧表示、且手卡或卡组存在可装备怪兽的怪兽
function c83152482.cfilter(c,tp)
	return c:IsFaceup()
		-- 检查手卡或卡组是否存在原本种族或原本属性相同的可装备怪兽
		and Duel.IsExistingMatchingCard(c83152482.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c:GetOriginalAttribute(),c:GetOriginalRace(),tp)
end
-- 过滤手卡或卡组中原本属性相同或原本种族相同、且可以放置在场上的怪兽
function c83152482.eqfilter(c,att,race,tp)
	return c:IsType(TYPE_MONSTER) and (c:GetOriginalAttribute()==att or c:GetOriginalRace()==race)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果①的发动准备与对象选择判定
function c83152482.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83152482.cfilter(chkc,tp) end
	-- 检查自己场上是否存在满足条件的表侧表示怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c83152482.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查自己的魔法与陷阱区域是否有可用的空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c83152482.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果①的处理：将手卡或卡组的怪兽作为装备卡装备给对象，并适用攻击力上升和特殊召唤限制
function c83152482.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若此时魔法与陷阱区域没有空位，则效果不适用
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从手卡或卡组选择1只原本种族或原本属性与对象怪兽相同的怪兽
		local g=Duel.SelectMatchingCard(tp,c83152482.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc:GetOriginalAttribute(),tc:GetOriginalRace(),tp)
		local sc=g:GetFirst()
		if not sc then return end
		local res=sc:IsLocation(LOCATION_DECK)
		-- 将选择的怪兽作为装备卡装备给对象怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,sc,tc) then return end
		-- 当作...装备卡使用给作为对象的怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(c83152482.eqlimit)
		sc:RegisterEffect(e1)
		-- 攻击力上升1000
		local e2=Effect.CreateEffect(sc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		if res then
			-- 这个效果从卡组装备的场合，直到回合结束时自己不能把那张装备的怪兽卡以及那些同名怪兽特殊召唤。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e3:SetTargetRange(1,0)
			e3:SetLabel(sc:GetCode())
			e3:SetTarget(c83152482.splimit)
			e3:SetReset(RESET_PHASE+PHASE_END)
			-- 注册不能特殊召唤同名怪兽的玩家效果
			Duel.RegisterEffect(e3,tp)
		end
	end
end
-- 装备限制：该卡只能装备给作为对象的怪兽
function c83152482.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤限制：不能特殊召唤与被装备怪兽同名的怪兽
function c83152482.splimit(e,c)
	return c:IsCode(e:GetLabel())
end
