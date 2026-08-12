--邪炎帝王テスタロス
-- 效果：
-- 这张卡可以把对方场上1只怪兽和上级召唤的1只自己怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合才能发动。对方手卡随机1张除外，给与对方1000伤害。把上级召唤的8星以上的怪兽解放让这张卡上级召唤的场合，可以再让以下效果适用。
-- ●场上1张卡除外，那张卡是炎·暗属性怪兽卡的场合，给与对方那个原本等级×200伤害。
local s,id,o=GetID()
-- 初始化函数：注册特殊上级召唤规则、素材检查效果以及上级召唤成功时的诱发效果
function s.initial_effect(c)
	-- 这张卡可以把对方场上1只怪兽和上级召唤的1只自己怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"把对方场上1只怪兽和上级召唤的1只自己怪兽解放作上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 把上级召唤的8星以上的怪兽解放让这张卡上级召唤的场合，可以再让以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.mchk)
	c:RegisterEffect(e3)
	-- ①：这张卡上级召唤的场合才能发动。对方手卡随机1张除外，给与对方1000伤害。把上级召唤的8星以上的怪兽解放让这张卡上级召唤的场合，可以再让以下效果适用。●场上1张卡除外，那张卡是炎·暗属性怪兽卡的场合，给与对方那个原本等级×200伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.rmcon)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选出自己场上通过上级召唤出场的怪兽
function s.tfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsControler(tp)
end
-- 检查函数：检查选取的解放素材组是否包含1只自己上级召唤的怪兽和1只对方怪兽，且满足怪兽区域数量限制
function s.tcheck(g,tp)
	return g:IsExists(s.tfilter,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
		-- 检查解放这些怪兽后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,g)>0
end
-- 特殊上级召唤的条件：手牌中的这张卡是7星以上，且场上存在满足解放条件的1只自己上级召唤的怪兽和1只对方怪兽
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上可以作为召唤解放的怪兽
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,LOCATION_MZONE,nil,REASON_SUMMON)
	return c:IsLevelAbove(7) and minc<=2 and g:CheckSubGroup(s.tcheck,2,2,tp)
end
-- 特殊上级召唤的操作：选择双方场上满足条件的各1只怪兽解放进行上级召唤
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上可以作为召唤解放的怪兽
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,LOCATION_MZONE,nil,REASON_SUMMON)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,s.tcheck,false,2,2,tp)
	c:SetMaterial(sg)
	-- 将选中的怪兽作为上级召唤的素材解放
	Duel.Release(sg,REASON_MATERIAL+REASON_SUMMON)
end
-- 过滤函数：筛选等级8以上且是上级召唤的怪兽
function s.mfilter(c)
	return c:IsLevelAbove(8) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 素材检查：检查解放素材中是否存在8星以上的上级召唤怪兽，并用Label标记结果
function s.mchk(e,c)
	if c:GetMaterial():IsExists(s.mfilter,1,nil) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 发动条件：这张卡上级召唤成功的场合
function s.rmcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果的目标与操作信息注册：检查对方手牌是否可除外，继承素材检查的Label，并注册除外和伤害的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	e:SetLabel(e:GetLabelObject():GetLabel())
	-- 获取对方手牌中可以除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 设置除外1张对方手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置给与对方1000点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：随机除外对方1张手牌并给与1000伤害；若满足特定素材条件，可选择再除外场上1张卡，若除外的是炎·暗属性怪兽则追加伤害
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 随机选择对方1张可以除外的手牌
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1)
	-- 成功除外对方手牌并成功给与对方1000伤害时
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and Duel.Damage(1-tp,1000,REASON_EFFECT)>0 then
		-- 获取场上所有可以除外的卡
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 若解放了8星以上的上级召唤怪兽，且场上有可除外的卡，则玩家可以选择是否适用追加效果
		if e:GetLabel()>0 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把场上1张卡除外？"
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local rc=rg:Select(tp,1,1,nil):GetFirst()
			-- 中断当前效果处理，使后续的除外和伤害处理不与前面的除外和伤害同时进行
			Duel.BreakEffect()
			-- 成功除外选中的场上的卡
			if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0
				and rc:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_FIRE)
				and rc:GetOriginalType()&TYPE_MONSTER>0
				and rc:GetOriginalLevel()>0 then
				-- 给与对方该怪兽原本等级×200的伤害
				Duel.Damage(1-tp,rc:GetOriginalLevel()*200,REASON_EFFECT)
			end
		end
	end
end
