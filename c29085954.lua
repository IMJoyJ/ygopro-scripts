--No.78 ナンバーズ・アーカイブ
-- 效果：
-- 1星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的额外卡组的卡由对方随机选1张。那是「No.1」～「No.99」其中任意种的「No.」怪兽的场合，那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。这个效果在对方回合也能发动。
function c29085954.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用1星怪兽作为素材，最少需要2只
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的额外卡组的卡由对方随机选1张。那是「No.1」～「No.99」其中任意种的「No.」怪兽的场合，那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29085954,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29085954.cost)
	e1:SetTarget(c29085954.sptg)
	e1:SetOperation(c29085954.spop)
	c:RegisterEffect(e1)
end
-- 设置该卡的No.编号为78
aux.xyz_number[29085954]=78
-- 支付效果代价，移除自身1个超量素材
function c29085954.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的额外卡组怪兽，包括No.1至99、属于No.卡组、可作为XYZ素材、可特殊召唤且场上存在召唤空间
function c29085954.filter(c,e,tp,mc)
	-- 获取卡片的No.编号
	local no=aux.GetXyzNumber(c)
	return no and no>=1 and no<=99 and c:IsSetCard(0x48)
		and mc:IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否可以被特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果的发动条件，检查自身是否有作为超量素材的必要条件且额外卡组存在符合条件的怪兽
function c29085954.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否有作为超量素材的必要条件
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c29085954.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置效果处理时的操作信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，从额外卡组随机选择一张怪兽并进行特殊召唤
function c29085954.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家额外卡组中的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 检查额外卡组是否非空且自身满足作为超量素材的必要条件
	if g:GetCount()>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 洗切玩家的额外卡组
		Duel.ShuffleExtra(tp)
		local tg=g:RandomSelect(1-tp,1)
		-- 确认对方查看随机选择的怪兽
		Duel.ConfirmCards(1-tp,tg)
		if tg:IsExists(c29085954.filter,1,nil,e,tp,c) then
			local tc=tg:GetFirst()
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将自身叠放的怪兽叠放到目标怪兽上
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 将自身叠放到目标怪兽上
			Duel.Overlay(tc,Group.FromCards(c))
			-- 将目标怪兽以超量召唤方式特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(29085954,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc:CompleteProcedure()
			-- 注册一个在结束阶段触发的效果，用于将特殊召唤的怪兽除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c29085954.rmcon)
			e1:SetOperation(c29085954.rmop)
			-- 将效果注册到全局环境
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 注册一个在回合结束时禁止自己特殊召唤怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否为当前效果所控制的怪兽，用于确保正确除外
function c29085954.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(29085954)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 将目标怪兽从场上除外
function c29085954.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
